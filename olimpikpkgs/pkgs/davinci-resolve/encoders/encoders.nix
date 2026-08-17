{
  callPackage,
}:
{
  ffmpeg = callPackage ./EdvinNilsson/ffmpeg-encoder-plugin { };
  
  vaapi = callPackage ./nowrep/dvcp-vaapi { };

  x264 = callPackage ./UDaManFunks/x264-encoder { };
  x265 = callPackage ./UDaManFunks/x265-encoder { };
  x265-10b = callPackage ./UDaManFunks/x265-encoder-10b { };
  prores-U = callPackage ./UDaManFunks/prores-encoder { };

  prores-j = callPackage ./jonny9f/resolve-prores { };

  aac = callPackage ./Toxblh/davinci-linux-aac-codec { };
  aac-fdk = callPackage ./hexitnz/resolve-linux-studio-aac-fdk-encoder-plugin { };
}
