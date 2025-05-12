{
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
      extraDefCfg = "process-unmapped-keys yes";
        config = ''
        (defsrc
            caps a s d f j k l ;
        )
        (defvar
          ;; Note: may need to change timing for pinikie vs index
          tap-time 300
          hold-time 250
        )
        (defalias
          caps (tap-hold $tap-time $hold-time esc lctl)
          a (tap-hold $tap-time $hold-time a lmet)
          s (tap-hold $tap-time $hold-time s lalt)
          d (tap-hold $tap-time $hold-time d lctl)
          f (tap-hold $tap-time $hold-time f lsft)
          j (tap-hold $tap-time $hold-time j rsft)
          k (tap-hold $tap-time $hold-time k rctl)
          l (tap-hold $tap-time $hold-time l ralt)
          ; (tap-hold $tap-time $hold-time ; rmet)
        )
        (deflayer base
            ;; tap caps lock as esc, hold caps lock as left control
            @caps @a @s @d @f @j @k @l @;
        )
        '';
      };
    };
  };
}
