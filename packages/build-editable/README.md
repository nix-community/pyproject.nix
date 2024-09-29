# build-editable

This package is intended to aid Nix-based Python development using [editable installs](https://pip.pypa.io/en/latest/topics/local-project-installs/#editable-installs).

This is to be used with build-systems such as `meson-python` that builds native extensions.
It's purpose is similar to that of `python setup.py build_ext -i`, just using PEP-660.

## Problems

Of course this is not a perfect analogy to using something like `meson-python` directly.
We just use the `.pth` machinery directly, while `meson-python` uses a more complex hook machinery:

- Automatic inference of Python

  `meson-python` puts the editable build in `build/cp312`.
  Users will have to manually override any editable root automatically inferred by Nix to point to the correct build directory.

- Automatic rebuilds

  Thanks to it's hook machinery `meson-python` can rebuild packages as necessary on load.
  This automatic rebuild behaviour will not work, and users will have to call `build-editable` manually.

These are just two examples of build-system specific behaviour that will not work out of the box.
