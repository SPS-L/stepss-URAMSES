# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

URAMSES is a Fortran framework for integrating custom user-defined models into PyRAMSES (Python) and STEPSS (Java) power system simulators. Users write Fortran model subroutines, register them in router files, and compile everything into a shared library (`ramses.so` / `ramses.dll`) or standalone executable (`dynsim`).

## Build Commands (Linux)

```bash
make -f Makefile.gfortran            # Build shared library + executable
make -f Makefile.gfortran dll        # Shared library only (ramses.so)
make -f Makefile.gfortran exe        # Executable only (dynsim)
make -f Makefile.gfortran clean      # Remove build artifacts
make -f Makefile.gfortran check-deps # Verify dependencies (gfortran, OpenBLAS, libramses.a)
```

Output goes to `Release_gnu_l/`. On Windows, use Visual Studio with `URAMSES.sln` and Intel oneAPI Fortran compiler.

## Build Commands (Docker)

```bash
docker compose build                       # One-time image build (~2 min)
docker compose run --rm uramses-build      # Build ramses.so → output/ramses.so
./build.sh                                 # Convenience wrapper for the above
```

No compiler or library installation needed on the host — the Docker image (Ubuntu 24.04) bundles gfortran and OpenBLAS. The repo root is bind-mounted into the container, so edits to `my_models/` are picked up without rebuilding the image.

## Architecture

**Build dependency chain:**
```
main.f90 → c_interface.f90 → usr_*_models.f90 → my_models/*.f90 + FUNCTIONS_IN_MODELS.f90
                                                        ↓
                                                 libramses.a (pre-compiled)
```

**Key directories:**
- `src/` — Framework code (C interface, model routers, utility functions, main entry point)
- `my_models/` — User model implementations (auto-discovered by Makefile on Linux)
- `modules_lin/` — Pre-compiled RAMSES library and `.mod` files (Linux/gfortran)
- `modules/` — Pre-compiled RAMSES library and `.mod` files (Windows/Intel)
- `docker/` — Dockerfile for containerized builds
- `output/` — Docker build output directory (ramses.so)

**Model router pattern** (`src/usr_*_models.f90`): Each file contains an `assoc_*_ptr` subroutine that maps string model names to Fortran subroutine pointers via `select case`. Five model categories exist: `exc` (exciters), `inj` (injectors), `tor` (torque/governors), `twop` (two-port devices), `dctl` (discrete control).

**Model subroutine pattern**: Each model in `my_models/` is a single subroutine using mode-based dispatch (`select case` on `mode`): `define_var_and_par`, `define_obs`, `diffstate`, `algstate`, `update_state`. Models use `FUNCTIONS_IN_MODELS` for shared utilities (`ppower`, `qpower`, `vrectif`, `vcomp`, etc.).

## Adding a New Model

1. Create `my_models/<type>_<NAME>.f90` following the naming convention (`exc_`, `inj_`, `tor_`, `twop_`, `dctl_`)
2. Register in the corresponding `src/usr_<type>_models.f90` by adding a `case` to the `select case` block
3. Rebuild: `make -f Makefile.gfortran clean all`

On Linux, the Makefile auto-discovers `.f90` files in `my_models/` via wildcard. On Windows, files must be manually added to the Visual Studio project.

## Fortran Conventions

- Free-form Fortran 90/95, compiled with `-ffree-line-length-none`
- Double precision throughout
- `#ifdef DLL` preprocessor guards for Windows DLL exports (`!DEC$ ATTRIBUTES DLLEXPORT`)
- OpenMP enabled (`-fopenmp`)
- `FUNCTIONS_IN_MODELS.f90` must compile before any model that `use`s it (enforced in Makefile)

## No Test Suite

There is no automated test framework. Models are validated through integration with PyRAMSES or STEPSS simulations.
