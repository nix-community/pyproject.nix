{ eggs, mocks, ... }:
let
  inherit (eggs)
    matchEggFileName
    isEggFileName
    parseEggFileName
    selectEggs
    ;

in

{
  matchEggFileName = {
    testSimple = {
      expr = matchEggFileName "python_editor-1.0.4-py3.5.egg";
      expected = [
        "python_editor"
        "1.0.4"
        "py3.5"
      ];
    };

    testSimpleNoMatch = {
      expr = matchEggFileName "distribution-1.0-1-py27-none-any.tar.gz";
      expected = null;
    };
  };

  isEggFileName = {
    testSimple = {
      expr = isEggFileName "python_editor-1.0.4-py3.5.egg";
      expected = true;
    };

    testSimpleNoMatch = {
      expr = isEggFileName "distribution-1.0-1-py27-none-any.tar.gz";
      expected = false;
    };
  };

  parseEggFileName = {
    testSimple = {
      expr = parseEggFileName "python_editor-1.0.4-py3.5.egg";
      expected = {
        filename = "python_editor-1.0.4-py3.5.egg";
        distribution = "python_editor";
        languageTag = {
          implementation = "python";
          version = "3.5";
        };
        version = "1.0.4";
      };
    };
  };

  selectEggs = {
    testFoo = {
      expr = map (egg: egg.filename) (
        selectEggs mocks.cpythonLinux38 (
          map parseEggFileName [
            "pyasn1_modules-0.2.7-py3.3.egg"
            "pyasn1_modules-0.2.7-py3.4.egg"
            "pyasn1_modules-0.2.7-py3.7.egg"
            "pyasn1_modules-0.2.7-py3.8.egg"
            "pyasn1_modules-0.2.7-py3.5.egg"
            "pyasn1_modules-0.2.7-py3.9.egg"
            "pyasn1_modules-0.2.7-py3.6.egg"
          ]
        )
      );
      expected = [
        "pyasn1_modules-0.2.7-py3.8.egg"
        "pyasn1_modules-0.2.7-py3.7.egg"
        "pyasn1_modules-0.2.7-py3.6.egg"
        "pyasn1_modules-0.2.7-py3.5.egg"
        "pyasn1_modules-0.2.7-py3.4.egg"
        "pyasn1_modules-0.2.7-py3.3.egg"
      ];
    };
  };
}
