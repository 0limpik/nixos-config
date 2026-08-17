{
  ffmpeg-full,
}:
(ffmpeg-full.override {
  withUnfree = true;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      #yt-dlp youtube
      #(stable.fetchpatch {
      #  url = "https://github.com/FFmpeg/FFmpeg/commit/618fc15e65f57c9ce25d4562f4b516129815608c.patch";
      #  sha256 = "sha256-Ufn6YslO1fvzSGtPPYGhtkjL3LaH6T2SJwGtdNU3OOo=";
      #})
    ];
  })
