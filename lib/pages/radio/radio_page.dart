import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_player/radio_player.dart';
// import 'package:vgs/controllers/old_radio_controller.dart';
import 'package:vgs/configs/http_client_config.dart';
import 'package:vgs/configs/radio_config.dart';
import 'package:vgs/controllers/radio_controller.dart';
import 'package:vgs/widgets/bannerad_widget.dart';
import 'package:vgs/widgets/navbar.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  // late final AppLifecycleListener _listener;
  bool _isPlaying = false;
  String _currentSong = 'Carregando...';
  String _currentArtist = '';
  String? _albumArtUrl;
  Uint8List? _streamArtworkBytes;
  StreamSubscription<Metadata>? _metadataSub;
  Timer? _songTimer;
  final Dio _dio = Dio();

  /// Igual ao `currentTrack` no player web: evita refetch iTunes se o texto não mudou.
  String? _lastNowPlayingRaw;

  void _listenStreamMetadata() {
    _metadataSub?.cancel();
    _metadataSub = RadioPlayer.metadataStream.listen(
      (Metadata m) {
        if (!mounted) return;
        final t = m.title?.trim() ?? '';
        final a = m.artist?.trim() ?? '';
        if (t.isEmpty && a.isEmpty) {
          return;
        }

        final bytes = m.artworkData;
        final icyUrl = m.artworkUrl?.trim() ?? '';

        setState(() {
          if (t.isNotEmpty) {
            _currentSong = t;
          }
          if (a.isNotEmpty) {
            _currentArtist = a;
          }
          if (bytes != null && bytes.isNotEmpty) {
            _streamArtworkBytes = bytes;
            _albumArtUrl = null;
          } else if (icyUrl.isNotEmpty) {
            _streamArtworkBytes = null;
            _albumArtUrl = icyUrl;
          }
        });

        // Fallback estilo iTune.js só se o nativo ainda não enviou capa
        final hasArt =
            (bytes != null && bytes.isNotEmpty) || icyUrl.isNotEmpty;
        if (!hasArt) {
          final q = a.isNotEmpty && t.isNotEmpty ? '$a - $t' : (t.isNotEmpty ? t : a);
          if (q.isNotEmpty) {
            _fetchAlbumArt(q);
          }
        }

        _updateNotification();
      },
      onError: (_) {},
    );
  }

  @override
  void initState() {
    super.initState();
    _dio.options.connectTimeout = const Duration(seconds: 12);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = <String, dynamic>{
      ...(Platform.isIOS
          ? HttpClientConfig.iosSafariLikeHeaders
          : HttpClientConfig.androidLikeHeaders),
    };
    // Força orientação portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _listenStreamMetadata();
    radioController.play();
    _updateStatus();
    _fetchCurrentSong();
    _startSongTimer();
  }

  void _startSongTimer() {
    _songTimer = Timer.periodic(RadioConfig.nowPlayingPollInterval, (timer) {
      if (_isPlaying) {
        _fetchCurrentSong();
      }
    });
  }

  /// Igual ao iTune.js: `data.replace(/<[^>]*>/g, '').trim()`.
  String _stripHtmlTags(String s) {
    return s.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  bool _isInvalidNowPlayingMessage(String s) {
    return s == 'Música não identificada' || s == 'Música não disponível';
  }

  // Limpa o nome da música removendo informações extras
  String _cleanSongName(String songName) {
    // Remove informações entre parênteses (Bonus Track, UK_Jap_Oz_Nz, etc)
    String cleaned = songName.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    
    // Remove informações extras comuns após hífen
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*Bonus\s*Track.*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*UK.*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*Jap.*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*Oz.*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*Nz.*', caseSensitive: false), '');
    
    // Remove múltiplos espaços
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove hífens extras no final
    cleaned = cleaned.replaceAll(RegExp(r'\s*-\s*$'), '');
    
    return cleaned.trim();
  }

  Future<void> _fetchCurrentSong() async {
    if (!mounted) return;

    final endpoints = <String>[];
    final meta = RadioConfig.metadataPhpUrl.trim();
    if (meta.isNotEmpty) {
      endpoints.add(meta);
    }
    endpoints.add(RadioConfig.nowPlayingFallbackUrl);

    Object? lastError;
    for (final url in endpoints) {
      try {
        final response = await _dio.get<String>(
          url,
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 12),
          ),
        );

        if (response.statusCode != 200 || response.data == null) {
          continue;
        }

        // Fluxo iTune.js: strip HTML + trim; o texto bruto vai ao iTunes (fetchCoverFromiTunes(data)).
        final raw = _stripHtmlTags(response.data!);
        if (raw.isEmpty) {
          continue;
        }

        if (raw == _lastNowPlayingRaw) {
          return;
        }

        if (_isInvalidNowPlayingMessage(raw)) {
          if (!mounted) return;
          _lastNowPlayingRaw = raw;
          setState(() {
            _currentSong = raw;
            _currentArtist = '';
            _albumArtUrl = null;
            _streamArtworkBytes = null;
          });
          _updateNotification();
          return;
        }

        _lastNowPlayingRaw = raw;

        final cleaned = _cleanSongName(raw);
        String? artist;
        String? track;
        if (cleaned.contains(' - ')) {
          final parts = cleaned.split(' - ');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            track = parts.sublist(1).join(' - ').trim();
          }
        }

        if (!mounted) return;
        final displayTitle = track ?? cleaned;
        final displayArtist = artist ?? '';
        final previousLine = _currentSong;

        setState(() {
          _currentSong = displayTitle;
          _currentArtist = displayArtist;
        });

        if (previousLine != displayTitle || (_albumArtUrl == null && _streamArtworkBytes == null)) {
          _updateNotification();
          // Mesmo termo de pesquisa que no iTune.js: string completa após remover HTML.
          _fetchAlbumArt(raw);
        } else {
          _updateNotification();
        }
        return;
      } catch (e) {
        lastError = e;
        continue;
      }
    }

    if (!mounted) return;
    if (_currentSong == 'Carregando...') {
      setState(() {
        _currentSong = 'Música não disponível';
        _currentArtist = '';
      });
    }
    if (lastError != null) {
      debugPrint('_fetchCurrentSong: todos os endpoints falharam: $lastError');
    }
  }

  Future<void> _fetchAlbumArt(String musicName) async {
    if (!mounted) return;
    
    try {
      // Seguir exatamente a lógica do iTune.js
      final query = Uri.encodeComponent(musicName);
      final url = 'https://itunes.apple.com/search?term=$query&media=music&limit=1';
      
      print('🎵 Buscando capa para: $musicName');
      print('🔗 URL: $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          headers: Map<String, dynamic>.from(HttpClientConfig.itunesSearchHeaders),
        ),
      );
      
      print('📡 Status: ${response.statusCode}');
      print('📦 Tipo de resposta: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Sempre converter para String e fazer parse (mais seguro)
        Map<String, dynamic> data;
        try {
          // Converter para String primeiro (evita problemas de tipo)
          String responseString;
          if (response.data is String) {
            responseString = response.data as String;
          } else {
            // Se não for String, converter
            responseString = response.data.toString();
          }
          
          print('🔄 Fazendo parse de String para JSON...');
          print('📄 Primeiros 200 caracteres: ${responseString.length > 200 ? responseString.substring(0, 200) : responseString}');
          
          // Fazer parse do JSON
          final jsonData = jsonDecode(responseString);
          
          // Verificar se é Map
          if (jsonData is! Map) {
            throw Exception('Resposta parseada não é um Map. Tipo: ${jsonData.runtimeType}');
          }
          
          data = Map<String, dynamic>.from(jsonData);
          print('✅ Parse concluído. Tipo: ${data.runtimeType}');
        } catch (e, stackTrace) {
          print('❌ Erro ao processar resposta: $e');
          print('📄 Tipo do response.data: ${response.data.runtimeType}');
          try {
            final str = response.data.toString();
            print('📄 Conteúdo (primeiros 500 chars): ${str.length > 500 ? str.substring(0, 500) : str}');
          } catch (_) {
            print('📄 Não foi possível converter response.data para String');
          }
          print('📚 Stack trace: $stackTrace');
          if (mounted) {
            setState(() {
              _albumArtUrl = null;
              _streamArtworkBytes = null;
            });
          }
          return;
        }
        print('📦 ResultCount: ${data['resultCount']}');
        
        // Verificar se tem results e se não está vazio (igual ao iTune.js)
        if (data['results'] != null && data['results'] is List && (data['results'] as List).isNotEmpty) {
          final results = data['results'] as List;
          final result = results[0];
          
          if (result is Map<String, dynamic>) {
            print('🎨 ArtworkUrl100: ${result['artworkUrl100']}');
            // iTune.js só altera a capa; título vem sempre do metadata.php/currentsong.
            // Pegar artworkUrl100 e substituir "100x100" por "300x300" (igual ao iTune.js)
            if (result['artworkUrl100'] != null) {
              String artwork = result['artworkUrl100'].toString();
              // Substituir qualquer variação de 100x100 (com ou sem bb)
              artwork = artwork.replaceAll('100x100bb', '300x300bb');
              artwork = artwork.replaceAll('100x100', '300x300');
              
              print('✅ Capa encontrada: $artwork');
              
              if (mounted) {
                setState(() {
                  _streamArtworkBytes = null;
                  _albumArtUrl = artwork;
                });
                await Future.delayed(const Duration(milliseconds: 100));
                _updateNotification();
              }
              return;
            }
          }
        } else {
          print('❌ Nenhum resultado encontrado ou results não é uma lista');
        }
      }
      
      // Se não encontrou, mantém null (mostra só a logo)
      print('⚠️ Capa não encontrada, mantendo logo');
      if (mounted) {
        setState(() {
          _albumArtUrl = null;
        });
        _updateNotification();
      }
    } catch (e, stackTrace) {
      // Em caso de erro, mantém null (mostra só a logo)
      print('❌ Erro ao buscar capa: $e');
      print('📚 Stack trace completo: $stackTrace');
      if (mounted) {
        setState(() {
          _albumArtUrl = null;
        });
        _updateNotification();
      }
    }
  }

  void _updateStatus() {
    setState(() {
      _isPlaying = radioController.isPlaying;
    });
  }

  // Atualiza a notificação de mídia com os dados da música atual
  Future<void> _updateNotification() async {
    if (!_isPlaying) return; // Só atualiza se estiver tocando
    
    try {
      String title = _currentSong.isNotEmpty && _currentSong != 'Carregando...' 
          ? _currentSong 
          : 'Ceres FM';
      String? subtitle = _currentArtist.isNotEmpty 
          ? _currentArtist 
          : null;
      
      await radioController.updateNotificationMetadata(
        title: title,
        subtitle: subtitle,
        artworkHttpUrl: _albumArtUrl,
      );
    } catch (e) {
      print('❌ Erro ao atualizar notificação: $e');
    }
  }

  // didChangeAppLifecycleState(AppLifecycleState state) {
  // if (state == AppLifecycleState.detached) {
  //   radioController.dispose();
  // }
  // }

  @override
  void dispose() {
    _metadataSub?.cancel();
    _songTimer?.cancel();
    radioController.pause();
    _dio.close();
    // radioController.dispose();
    // radioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Garante orientação portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/radio_background.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: const Navbar(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 0.0),
            child: Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: Color.fromARGB(255, 62, 223, 207),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
        body: Center(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Capa do álbum grande e arredondada (tamanho da foto)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.width * 0.85,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Logo da rádio (fundo)
                            Image.asset(
                              'assets/images/ceresfm.png',
                              fit: BoxFit.cover,
                            ),
                            // Capa: bytes do stream (ICY + iTunes nativo) ou URL (iTunes / ICY)
                            if (_streamArtworkBytes != null &&
                                _streamArtworkBytes!.isNotEmpty)
                              Image.memory(
                                _streamArtworkBytes!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            else if (_albumArtUrl != null &&
                                _albumArtUrl!.isNotEmpty)
                              Image.network(
                                _albumArtUrl!,
                                headers: Platform.isIOS
                                    ? HttpClientConfig.iosSafariLikeHeaders
                                    : HttpClientConfig.androidLikeHeaders,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.black12,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nome da rádio (fonte maior como na imagem)
                    const Text(
                      'Ceres FM',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentArtist.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _currentArtist,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (_currentArtist.isNotEmpty) const SizedBox(height: 4),
                    // Nome da música/artista (fonte menor como na imagem)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _currentSong.isEmpty ? 'Artista Desconhecido' : _currentSong,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Barra de progresso (duas linhas curtas teal)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.teal[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 18,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.teal[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Botão de play/pause (teal)
                    ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(70, 70)),
                        shape: WidgetStateProperty.all(const CircleBorder()),
                        backgroundColor: WidgetStateProperty.all(Colors.teal[400]),
                        elevation: WidgetStateProperty.all(4),
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () {
                        if (_isPlaying) {
                          radioController.pause();
                        } else {
                          radioController.play();
                        }
                        _updateStatus();
                      },
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const BannerAdWidget()
            ],
          ),
        ),
      ),
    );
  }
}
