(define-module (files packages NaitreHUD package)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix build-system meson)
  #:use-module (guix licenses))


(define-public naitre
  (let ((commit "fe813d7b157c2d290a79cc863387800e99f1f1eb")
        (revision "1"))
  (package
    (name "naitre")
    (version(git-version "1.0.0" revision commit))
    (source (origin
             (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/nixpup/NaitreHUD")
                   (commit commit)))
             (file-name (git-file-name name version))
             (sha256
              (base32
               "1jbkpcrdw1yqfqnijgfchs0w2iy2ncw9a18h5czvsgcfk5hji4fj"))
             ))
    (build-system meson-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "-Dsysconfdir=" #$output "/etc"))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'configure 'patch-meson
            (lambda _
              (substitute* "meson.build"
                (("'-DSYSCONFDIR=\\\"@0@\\\"'.format\\('/etc'\\)")
                 "'-DSYSCONFDIR=\"@0@\"'.format(sysconfdir)")
                (("sysconfdir = sysconfdir.substring\\(prefix.length\\(\\)\\)")
                 ""))))
          (add-after 'install 'install-desktop-file
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (wayland-sessions (string-append out "/share/wayland-sessions")))
                (mkdir-p wayland-sessions)
                (call-with-output-file (string-append wayland-sessions "/naitre.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]
Encoding=UTF-8
Name=NaitreHUD
Comment=NaitreHUD Wayland WM
Exec=~a/bin/naitre
Type=Application
DesktopNames=NaitreHUD
"
                            out)))))))))
    (inputs (list wayland
                  libinput
                  libdrm
                  libxkbcommon
                  pixman
                  libdisplay-info
                  libliftoff
                  hwdata
                  seatd
                  pcre2
                  libxcb
                  xcb-util-wm
                  wlroots
                  scenefx))
    (native-inputs (list pkg-config wayland-protocols))
    (home-page "https://github.com/nixpup/NaitreHUD")
    (synopsis "Wayland Compositor and Window Manager")
    (description "A Wayland compositor based on wlroots and scenefx,
inspired by dwl but aiming to be more feature-rich.")
    (license gpl3))))

naitre
