
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'songs.dart';

import 'package:web_scraper/web_scraper.dart';
import 'package:audio_service/audio_service.dart';


import 'dart:async';
import 'dart:io';
import 'mediaitemmaker.dart';
//import 'package:audioplayers/audio_cache.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'song_decode.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'song_url.dart';
import 'dart:math';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';

///TODO move database to redis

import 'main.dart';


typedef void OnError(Exception exception);

List<String> songList = List<String>();
List<String> songInfo = List<String>();
List<String> poweredBy = List<String>();

List<MusicPlayer> musicPlayerList = List<MusicPlayer>();
List<String> favList = List<String>();
List<String> favInfo = List<String>();
int countMusicPlayer = 0;

var tempInt;

MediaControl playControl = MediaControl(
  //androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  //androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  //androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  //androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  //androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

final lengthOfList = songList.length;
String _getUrl() {
    
  print("songURL.length = ${songURL.length}");
  var rng = new Random();
  var temp = rng.nextInt(songURL.length); //size of songList
  tempInt = temp;
  number = temp;
  addToQueue();
  queue.add(new MediaItem(id: songURL[temp], title: songTitle[temp], album: songAlbumDate[temp]));
  for (int i = 0; i < queue.length; i++)
    print("${queue[i].id}");
  
  return songURL[temp];
}
var number;


var loading = false;

class SongUI extends StatelessWidget {

  
 

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      bottomNavigationBar: Container(
        height: AppBar().preferredSize.height,
        alignment: Alignment.center,
        child: BottomAppBar(
        color: Colors.blue[400],
        child: 
            
              Align(
                alignment: Platform.isIOS ? Alignment.bottomCenter : Alignment.center, //alignment issues with ios
          child: Text(
          "Inspired by Relisten.net",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            
            ),
          ),
        ),
          
        ),
       
      ),
      appBar: AppBar(
        titleSpacing: 0.0,
        
        backgroundColor: Colors.blue[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            
          }
        ),
        centerTitle: false,
        //backgroundColor: Colors.grey[500],
        title: Text(
          
          "Go back and select new bands",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w300
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Expanded(
              
          
              child: new ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Material(
                  
                  color: Colors.grey[200],
                  child: Column(
                     
                     children: [
                       MusicPlayer(),
                       
                     ],
                   
                    
                  ),
                  
                ),
              ),
            ),
          ),

          
          

          
        ],
      ),
      ),
    );
  }
}


class MusicPlayer extends StatefulWidget {
  

  MusicPlayer(
    {Key key})
    : super(key: key);

  @override
  State<StatefulWidget> createState() {
    
    return MusicPlayerState();
  }
  
}



AudioPlayer audioPlayer = new AudioPlayer();

/// TODO make the UI separate from the audio task,
/// such that the audio task is in the background player
/// while the user retains control wherever they choose
/// to control the audio player from

class MusicPlayerState extends State<MusicPlayer> {
  
  final _volumeSubject = BehaviorSubject.seeded(1.0);
  final _speedSubject = BehaviorSubject.seeded(1.0);
  
  //AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  //var playerSubscription;
  
  MusicPlayerState();

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    var temp = _getUrl();
    audioPlayer.setUrl(temp);
    var playerSubscription = audioPlayer.playbackStateStream.listen((event) { 
      if (event == AudioPlaybackState.completed) {
        newSong();
      }
    });
    
    
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    //playerSubscription.cancel();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        
        
        
        StreamBuilder<Duration>(
          stream: audioPlayer.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            
            
            return StreamBuilder<Duration>(
              stream: audioPlayer.getPositionStream(),
              builder: (context, snapshot) {
                var position = snapshot.data ?? Duration.zero;
                if (position > duration) {
                  
                 
                  position = duration;
                              
                    
                }

                

                ///this solved the problem of getting new song and background getting
                //audioPlayer.getPositionStream().listen((event) {
                  //if ((event == duration) && duration != Duration.zero) newSong();
                //});
                
                
                return SeekBar(
                  player: audioPlayer,
                  
                  duration: duration,
                  position: position ?? max(Duration.zero, min(position, duration)),//duration >= position ? position : Duration.zero,
                  onChangeEnd: (newPosition) {
                    audioPlayer.seek(newPosition);
                  },
                );
              },
            );
          }
        ),
        
        
        Text("\nVolume"),
        StreamBuilder<double>(
          stream: _volumeSubject.stream,
          builder: (context, snapshot) => Padding(
            padding: EdgeInsets.all(8.0),
            child: Slider.adaptive(
            //divisions: 16,
            min: 0.0,
            max: 2.0,
            value: snapshot.data ?? 1.0,
            onChanged: (value) {
              _volumeSubject.add(value);
              audioPlayer.setVolume(value);
            },
            ),
          ),
        ),
        Text("Speed"),
        StreamBuilder<double>(
          stream: _speedSubject.stream,
          builder: (context, snapshot) => Padding(
            padding: EdgeInsets.all(8.0),
            child: Slider.adaptive(
            divisions: 10,
            min: 0.5,
            max: 1.5,
            value: snapshot.data ?? 1.0,
            onChanged: (value) {
              _speedSubject.add(value);
              audioPlayer.setSpeed(value);
            },
          ),
          )
        ),
        
        
        
        
        
        
      ],
    );
  }

  Future<String> newSong() async {
    var temporaryURL = _getUrl();
    setState(() {
      loading = true;
    });
    await audioPlayer.setUrl(temporaryURL);
      setState(() {
        loading = false;
      });
    
    audioPlayer.play();
     
    var tempString = songTitle[tempInt] + "\n" + songArtist[tempInt] + "\n" + songAlbumDate[tempInt] + "\n";
    return tempString;
    
  }

  Future<void> playit() async {
    await audioPlayer.play();
  }
  
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;
  final AudioPlayer player;
  
  SeekBar({
    @required this.duration,
    @required this.position,
    @required this.player,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double _dragValue = null;

  get _durationText => widget.duration?.toString()?.split('.')?.first ?? '';
  get _positionText => widget.position?.toString()?.split('.')?.first ?? '';

  double max() => (widget.duration.inMilliseconds ?? 0.0).toDouble();
  double progress() => max() > (widget.position?.inMilliseconds ?? 0).toDouble()
                        ? (widget.position?.inMilliseconds ?? 0).toDouble()
                        : 0.0;

  Future<String> newSong() async {
    var temporaryURL = _getUrl();
    setState(() {
      loading = true;
    });
    await widget.player.setUrl(temporaryURL);
    setState(() {
      loading = false;
    });
    
    widget.player.play();
    var tempString = songTitle[tempInt] + "\n" + songArtist[tempInt] + "\n" + songAlbumDate[tempInt] + "\n"; 

    return tempString;
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height *7/24,
            width: MediaQuery.of(context).size.width * 7/8,
            child: Center(
              child: AutoSizeText(
                "${songTitle[tempInt]}\n${songArtist[tempInt]}\n${songAlbumDate[tempInt]}\n${songSource[tempInt]}",
                textAlign: TextAlign.center,
                maxLines: 5,
                minFontSize: 17,
                maxFontSize: 24,
                style: TextStyle(
                  fontSize: 24.0, 
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
          ),

          
          
        ),
        //Text("Track position"),
        Slider(
          min: 0.0,
          max: widget?.duration?.inMilliseconds?.toDouble() > 0.0 ? widget.duration.inMilliseconds.toDouble() : 0.0,
          value: _dragValue ?? math.max(0.0, min(widget.position.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble())),
          //value: widget?.position?.inMilliseconds?.toDouble() ?? (_dragValue ?? 0.0) ? (_dragValue ?? 0.0): 0.0,
          //value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
          onChanged: (value) async {
            if (value > widget.duration.inMilliseconds.toDouble()) {
              setState(() {
                value = widget.duration.inMilliseconds.toDouble();
                _dragValue = value;
              });
              
            }
            else if (value < 0.0) {
              setState(() {
                value = 0.0;
                _dragValue = value;
              });
            }
            else {
              setState(() {
                _dragValue = value;
              });
            }
            
            if (widget.onChanged != null) {
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            _dragValue = null;
            setState(() {
              if (value > widget.duration.inMilliseconds.toDouble()) {
                value = widget.duration.inMilliseconds.toDouble();
                
              }
              else if (value < 0.0) {
                value = 0.0;
              }
            });

            //get a new song if the song duration is pushed past the end
            //set the value of the song back to start
            if (value == widget.duration.inMilliseconds.toDouble()) {
              newSong();
              setState(() {
                value = 0.0;
              });
            }
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            
          },
        ),
        Text(
              widget.position != null ? '${_positionText ??''} / ${_durationText ?? ''}'
                                : widget.duration != null ? _durationText : '',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
        ),
        SizedBox(width: 10, height: 10),
        StreamBuilder<FullAudioPlaybackState> (
          stream: widget.player.fullPlaybackStateStream,
          builder: (context, snapshot) {
            final fullState = snapshot.data;
            var state = fullState?.state;
            final buffering = fullState?.buffering;
            
            
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state == AudioPlaybackState.connecting || buffering == true)
                  Container(
                    margin: EdgeInsets.all(8.0),
                    width: 64.0,
                    height: 64.0,
                    child: CircularProgressIndicator(),
                  )
                else if (state == AudioPlaybackState.playing) 
                  IconButton(
                    icon: Icon(Icons.pause),
                    iconSize: 64.0,
                    onPressed: () {
                      
                      widget.player.pause();
                    }
                  )
                else 
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    iconSize: 64.0,
                    onPressed: () {
                      
                      widget.player.play();
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 64.0,
                  onPressed: state == AudioPlaybackState.stopped ||
                              state == AudioPlaybackState.none
                              ? null
                              : () {
                                
                                widget.player.stop();
                              },
                            
                ),
                
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 64.0,
                  onPressed: state == AudioPlaybackState.connecting || buffering == true ? null : () {
                                      
                    newSong();

                  }
                ),
                
                
              ],
            );
          },
        ),
      ],
    ),
    );
  }

}

/// so there needs to be a background task class
/// that is basically the same as the normal audio player class i use 
/// to play music that allows the use of background controls and background
/// play of music
/// 

void myBackgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => MyBackgroundTask());
}

class MyBackgroundTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  bool _playing;
    //int _queueIndex = -1;
  //AudioPlayer _audioPlayer = new AudioPlayer();
  //Completer _completer = Completer();
  BasicPlaybackState _skipState;
  //bool _playing;

  bool get hasNext => queueIndex + 1 < queue.length;

  bool get hasPrevious => queueIndex > 0;

  MediaItem get mediaItem => queue[queueIndex];

  List<MediaControl> _playControls = [
    skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
  ];

  List<MediaControl> _pauseControls = [
    skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
  ];

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }

    BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    if (event.buffering) {
      return BasicPlaybackState.buffering;
    } else {
      switch (event.state) {
        case AudioPlaybackState.none:
          return BasicPlaybackState.none;
        case AudioPlaybackState.stopped:
          return BasicPlaybackState.stopped;
        case AudioPlaybackState.paused:
          return BasicPlaybackState.paused;
        case AudioPlaybackState.playing:
          return BasicPlaybackState.playing;
        case AudioPlaybackState.connecting:
          return _skipState ?? BasicPlaybackState.connecting;
        case AudioPlaybackState.completed:
          return BasicPlaybackState.stopped;
        default:
          throw Exception("Illegal state");
      }
    }
  }
  
  @override
  Future<void> onStart() async {
    // Your custom dart code to start audio playback.
    // NOTE: The background audio task will shut down
    // as soon as this async function completes.
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(queue);
    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

    void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

   void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

    Future<void> _skip(int offset) async {
    final newPos = queueIndex + offset;
    if (!(newPos >= 0 && newPos < queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  @override
  void onStop() {
    // Your custom dart code to stop audio playback. e.g.:
    _audioPlayer.stop();
    // Cause the audio task to shut down.
    _completer.complete();
  }
  @override
  void onPlay() {
    // Your custom dart code to resume audio playback. e.g.:
    _audioPlayer.play();
    // Broadcast the state change to all user interfaces:
    AudioServiceBackground.setState(
      basicState: BasicPlaybackState.playing,
      controls: _playControls
    );
  }
  @override
  void onPause() {
    // Your custom dart code to pause audio playback. e.g.:
    _audioPlayer.pause();
    // Broadcast the state change to all user interfaces:
    AudioServiceBackground.setState(
      basicState: BasicPlaybackState.paused,
      controls: _pauseControls,
    );
  }
  @override
  void onClick(MediaButton button) {
    // Your custom dart code to handle a click on a headset.
  }

  @override
  void onSeekTo(int position) {
    // Your custom dart code to seek to a position.
  }
}

/////
///
/// need to figure out displaying controls
/// 
/// 