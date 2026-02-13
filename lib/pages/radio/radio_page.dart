import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:vgs/controllers/old_radio_controller.dart';
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
  String? _albumArtLocalPath;
  Timer? _songTimer;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    // Força orientação portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    radioController.play();
    _updateStatus();
    _fetchCurrentSong();
    _startSongTimer();
  }

  void _startSongTimer() {
    _songTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isPlaying) {
        _fetchCurrentSong();
      }
    });
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
    
    try {
      final response = await _dio.get(
        'https://stm50.srvstm.com:11828/currentsong?sid=1',
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        String songName = response.data.toString().trim();
        if (songName.isNotEmpty) {
          // Limpa o nome da música antes de exibir
          final cleanedSongName = _cleanSongName(songName);
          
          // Tenta separar artista e música se vier no formato "Artista - Música"
          String? artist;
          String? track;
          if (cleanedSongName.contains(' - ')) {
            final parts = cleanedSongName.split(' - ');
            if (parts.length >= 2) {
              artist = parts[0].trim();
              track = parts.sublist(1).join(' - ').trim();
            }
          }
          
          // Sempre atualiza e busca capa quando a música muda
          if (mounted) {
            final previousSong = _currentSong;
            setState(() {
              // Se conseguiu separar, usa o nome da música separado
              // Caso contrário, usa o nome completo como música
              _currentSong = track ?? cleanedSongName;
              _currentArtist = artist ?? '';
            });
            // Buscar capa do álbum sempre que a música mudar ou na primeira vez
            print('🎶 Música original: $songName');
            print('🎶 Música limpa: $cleanedSongName (anterior: $previousSong)');
            print('🎤 Artista separado: $artist');
            print('🎵 Música separada: $track');
            print('🖼️ Capa atual: $_albumArtUrl');
            if (previousSong != (track ?? cleanedSongName) || _albumArtUrl == null) {
              print('🔄 Buscando nova capa...');
              // Atualiza a notificação imediatamente com os dados disponíveis
              _updateNotification();
              // Usa o nome limpo para buscar a capa (pode incluir artista)
              _fetchAlbumArt(cleanedSongName);
            } else {
              print('⏭️ Mantendo capa atual');
              // Atualiza a notificação mesmo se a música não mudou (caso os dados do iTunes tenham mudado)
              _updateNotification();
            }
          }
        }
      }
    } catch (e) {
      // Se houver erro, mantém a música anterior ou mostra mensagem
      if (mounted && _currentSong == 'Carregando...') {
        setState(() {
          _currentSong = 'Sem informação';
        });
      }
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
            print('🎤 Artista: ${result['artistName']}');
            print('🎵 Música: ${result['trackName']}');
            
            // Atualizar artista e música se disponíveis
            if (mounted) {
              setState(() {
                if (result['artistName'] != null) {
                  _currentArtist = result['artistName'].toString();
                }
                if (result['trackName'] != null && result['trackName'].toString().isNotEmpty) {
                  _currentSong = result['trackName'].toString();
                }
              });
            }
            
            // Pegar artworkUrl100 e substituir "100x100" por "300x300" (igual ao iTune.js)
            if (result['artworkUrl100'] != null) {
              String artwork = result['artworkUrl100'].toString();
              // Substituir qualquer variação de 100x100 (com ou sem bb)
              artwork = artwork.replaceAll('100x100bb', '300x300bb');
              artwork = artwork.replaceAll('100x100', '300x300');
              
              print('✅ Capa encontrada: $artwork');
              
              if (mounted) {
                setState(() {
                  _albumArtUrl = artwork;
                });
                // Baixa e salva a imagem localmente para usar na notificação
                await _downloadAndSaveAlbumArt(artwork);
                // Aguarda um pouco antes de atualizar a notificação
                await Future.delayed(const Duration(milliseconds: 100));
                // Atualiza a notificação com os novos dados
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
          _albumArtLocalPath = null;
        });
        // Atualiza a notificação mesmo sem a capa
        _updateNotification();
      }
    } catch (e, stackTrace) {
      // Em caso de erro, mantém null (mostra só a logo)
      print('❌ Erro ao buscar capa: $e');
      print('📚 Stack trace completo: $stackTrace');
      if (mounted) {
        setState(() {
          _albumArtUrl = null;
          _albumArtLocalPath = null;
        });
        // Atualiza a notificação mesmo com erro
        _updateNotification();
      }
    }
  }

  void _updateStatus() {
    setState(() {
      _isPlaying = radioController.isPlaying;
    });
  }

  // Baixa e salva a capa do álbum localmente
  Future<void> _downloadAndSaveAlbumArt(String imageUrl) async {
    try {
      print('📥 Baixando capa do álbum: $imageUrl');
      
      // Obtém o diretório temporário
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/album_art_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Baixa a imagem
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        // Salva a imagem no arquivo
        final file = File(filePath);
        await file.writeAsBytes(response.data as List<int>);
        
        print('✅ Capa salva localmente: $filePath');
        
        if (mounted) {
          setState(() {
            _albumArtLocalPath = filePath;
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao baixar capa do álbum: $e');
      if (mounted) {
        setState(() {
          _albumArtLocalPath = null;
        });
        // Atualiza a notificação mesmo se o download falhar
        _updateNotification();
      }
    }
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
      
      // Atualiza a notificação através do controller
      await radioController.updateNotificationMetadata(
        title: title,
        subtitle: subtitle,
        albumArtPath: _albumArtLocalPath,
      );
      
      print('📱 Notificação atualizada: $title ${subtitle != null ? '- $subtitle' : ''}');
      print('📱 Capa na notificação: ${_albumArtLocalPath ?? "logo padrão"}');
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
                            // Capa do álbum (sobreposta quando disponível)
                            if (_albumArtUrl != null && _albumArtUrl!.isNotEmpty)
                              Image.network(
                                _albumArtUrl!,
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
