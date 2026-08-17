{
  handbrake,
  amf,
  amf-headers,
}:
handbrake.overrideAttrs (attrs: {
  configureFlags = (attrs.configureFlags or [ ]) ++ [
    "--enable-vce"
  ];
  buildInputs = (attrs.buildInputs or [ ]) ++ [
    amf
  ];
  nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [
    amf-headers
  ];
  postInstall = (attrs.postInstall or "") + ''
    wrapProgram $out/bin/ghb \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${amf}/lib"
    wrapProgram $out/bin/HandBrakeCLI \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${amf}/lib"
  '';
})
