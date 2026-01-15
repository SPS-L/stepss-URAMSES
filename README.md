# URAMSES - User Models for PyRAMSES

## About

URAMSES is a project that enables the integration of custom user models into PyRAMSES (Python interface for RAMSES power system simulator) and STEPSS. This repository provides the framework and tools needed to compile and link your own Fortran models with the simulation environment.

**Author:** Sustainable Power Systems Lab (SPS-L)  
**Website:** [https://sps-lab.org](https://sps-lab.org)  
**Contact:** info@sps-lab.org  
**Last Edited:** January 2026

## Prerequisites

### Windows
- **Microsoft Visual Studio** (2019 or later recommended)
- **Intel oneAPI Fortran Compiler** (formerly Intel Fortran)
- **PyRAMSES** (Python package) or **STEPSS** (Java package)

For detailed installation instructions of the Intel oneAPI Fortran compiler, refer to the included PDF:
[Installing the Intel oneAPI Fortran compiler.pdf](Installing%20the%20Intel%20oneAPI%20Fortran%20compiler.pdf)

### Linux
- **gfortran** (GNU Fortran compiler)
- **OpenBLAS** (optimized BLAS library)
- **PyRAMSES** (Python package)

Install dependencies on your Linux distribution:

```bash
# Ubuntu/Debian
sudo apt install gfortran libopenblas-dev

# Fedora/RHEL
sudo dnf install gcc-gfortran openblas-devel

# Arch Linux
sudo pacman -S gcc-fortran openblas
```

## Project Structure

```
URAMSES/
├── src/                    # Source code files (common for Windows/Linux)
│   ├── c_interface.f90     # C interface for Python integration
│   ├── main.f90            # Main entry point (executable only)
│   ├── FUNCTIONS_IN_MODELS.f90  # Helper functions for models
│   ├── usr_exc_models.f90  # Exciter model associations
│   ├── usr_inj_models.f90  # Injector model associations
│   ├── usr_tor_models.f90  # Torque model associations
│   ├── usr_twop_models.f90 # Two-port model associations
│   └── usr_dctl_models.f90 # Discrete control model associations
├── my_models/              # Your custom models (common for Windows/Linux)
│   ├── exc_*.f90           # Exciter models
│   ├── inj_*.f90           # Injector models
│   ├── tor_*.f90           # Torque models
│   ├── twop_*.f90          # Two-port models
│   └── *.txt               # Model parameter files
├── modules/                # Pre-compiled modules (Windows/Intel Fortran)
│   ├── *.mod               # Module interface files
│   └── libramses.lib       # Pre-compiled RAMSES library
├── modules_lin/            # Pre-compiled modules (Linux/gfortran)
│   ├── *.mod               # Module interface files
│   └── libramses.a         # Pre-compiled RAMSES library
├── URAMSES.sln             # Visual Studio solution file (Windows)
├── dllramses.vfproj        # DLL project - ramses.dll (Windows)
├── exeramses.vfproj        # Executable project - dynsim.exe (Windows)
├── MDL.vfproj              # Model library project (Windows)
├── Makefile.gfortran       # Makefile for Linux builds
├── Release_intel_w64/      # Compiled output (Windows)
└── Release_gnu_l/          # Compiled output (Linux)
```

## Visual Studio Projects (Windows)

The solution contains three main projects:

### 1. dllramses (ramses.dll)
- **Purpose**: Creates the main dynamic link library for PyRAMSES integration
- **Output**: `ramses.dll` - Used by PyRAMSES to access your custom models
- **Usage**: Primary project for Python integration on Windows

### 2. exeramses (dynsim.exe)
- **Purpose**: Creates a standalone executable for direct simulation
- **Output**: `dynsim.exe` - Command-line simulation tool
- **Usage**: Run simulations directly without Python/Java interface
- **Features**: Includes all your custom models for standalone operation

## Model Types

URAMSES supports several types of power system models:

- **Exciters (`exc_*`)**: Generator excitation system models
- **Injectors (`inj_*`)**: Current/voltage injection models for faults/disturbances
- **Torque (`tor_*`)**: Mechanical torque models for generators
- **Two-port (`twop_*`)**: Two-port network models (e.g., SVC, STATCOM)
- **Discrete Control (`dctl_*`)**: Discrete control system models

## Building on Linux

### Quick Start

```bash
# Check dependencies and build
make -f Makefile.gfortran

# Or explicitly
make -f Makefile.gfortran all
```

### Build Process

1. **Check dependencies**: The Makefile automatically verifies that gfortran and OpenBLAS are installed
2. **Auto-detect sources**: Automatically finds all `.f90` files in `src/` and `my_models/` directories
3. **Compile sources**: Compiles all detected source files
4. **Link**: Links against pre-compiled `libramses.a` from `modules_lin/` and OpenBLAS
5. **Output**: Creates `ramses.so` and `dynsim` in `Release_gnu_l/`

**Note**: The Makefile uses `wildcard` to automatically detect all `.f90` files in `my_models/`. You don't need to manually add new model files to the Makefile - just place them in `my_models/` and rebuild.

### Makefile Targets

```bash
make -f Makefile.gfortran all        # Build both ramses.so and dynsim (default)
make -f Makefile.gfortran dll        # Build only ramses.so (shared library)
make -f Makefile.gfortran exe        # Build only dynsim (executable)
make -f Makefile.gfortran clean      # Remove build artifacts
make -f Makefile.gfortran check-deps # Verify dependencies
make -f Makefile.gfortran help       # Show help
```

### How the Makefile Works

The Makefile automatically discovers and compiles all source files:

1. **Source Files** (`src/`): All `.f90` files except `main.f90` (which is only used for the executable)
2. **Model Files** (`my_models/`): All `.f90` files are automatically detected using `wildcard`
3. **Compilation**: Each `.f90` file is compiled to a `.o` object file in `Release_gnu_l/obj/`
4. **Linking**: 
   - `ramses.so`: Links all object files (except `main.o`) into a shared library
   - `dynsim`: Links all object files (including `main.o`) into an executable

**Key Features**:
- ✅ Automatic model detection - no Makefile editing required
- ✅ Dependency tracking - only recompiles changed files
- ✅ Linux-only - Windows builds use Visual Studio
- ✅ Links against pre-compiled `libramses.a` and OpenBLAS

### Output

After successful build, the following files will be in `Release_gnu_l/`:
```
Release_gnu_l/ramses.so   # Shared library for PyRAMSES
Release_gnu_l/dynsim      # Standalone executable
```

## Building on Windows

### Step-by-Step Process

1. **Open Solution**: Open `URAMSES.sln` in Microsoft Visual Studio
2. **Verify Compiler**: Ensure Intel Fortran compiler is properly configured
3. **Select Configuration**: Choose `Release|x64` configuration
4. **Build**: Right-click solution → "Build Solution"

### Output Files

All compiled files will be created in `Release_intel_w64/`:
- `ramses.dll` - For PyRAMSES/STEPSS integration
- `dynsim.exe` - Standalone executable

## Adding Custom Models

### Step-by-Step Process

#### 1. Create Your Model File
Place your generated `.f90` model files (created by CODEGEN) into the `my_models/` directory. The Makefile will automatically detect and compile any `.f90` files in this directory.

**Example**: If you create `my_models/exc_MYMODEL.f90`, it will be automatically included in the build.

#### 2. Register Model in Association Files
Edit the appropriate association file in `src/` to register your models. This tells RAMSES which subroutine to call for your model.

**For Exciters** (`src/usr_exc_models.f90`):
```fortran
select case (modelname)
   case('YOUR_MODEL_NAME')
      exc_ptr => your_model_subroutine
end select
```

**For Injectors** (`src/usr_inj_models.f90`):
```fortran
select case (modelname)
   case('YOUR_MODEL_NAME')
      inj_ptr => your_model_subroutine
end select
```

**For Torque Models** (`src/usr_tor_models.f90`):
```fortran
select case (modelname)
   case('YOUR_MODEL_NAME')
      tor_ptr => your_model_subroutine
end select
```

**For Two-port Models** (`src/usr_twop_models.f90`):
```fortran
select case (modelname)
   case('YOUR_MODEL_NAME')
      twop_ptr => your_model_subroutine
end select
```

**For Discrete Control Models** (`src/usr_dctl_models.f90`):
```fortran
select case (modelname)
   case('YOUR_MODEL_NAME')
      dctl_ptr => your_model_subroutine
end select
```

**Important**: The `modelname` in the `case` statement must match exactly the name used in your simulation case files.

#### 3. Add to Visual Studio Project (Windows Only)
For Windows builds, you need to manually add the model file to the Visual Studio project:
1. Right-click on the `dllramses` project in Solution Explorer
2. Select "Add" → "Existing Item"
3. Navigate to `my_models/` and select your `.f90` files
4. Click "Add"

**Note**: For Linux builds, this step is **not required**. The Makefile automatically detects all `.f90` files in `my_models/` using `wildcard`, so your new model will be compiled automatically.

#### 4. Rebuild
- **Linux**: 
  ```bash
  make -f Makefile.gfortran clean all
  ```
  The Makefile will automatically compile your new model file(s) from `my_models/`.

- **Windows**: Rebuild the solution in Visual Studio (Build → Rebuild Solution)

### Automatic Model Detection

The Makefile uses the following pattern to automatically find all model files:
```makefile
MY_MODEL_FILES = $(wildcard $(MY_MODELS_DIR)/*.f90)
```

This means:
- ✅ Any `.f90` file placed in `my_models/` is automatically detected
- ✅ No need to edit the Makefile when adding new models
- ✅ Simply place your model file and rebuild

### Model File Naming Conventions

While not strictly required, following naming conventions helps organization:
- **Exciters**: `exc_*.f90` (e.g., `exc_MYMODEL.f90`)
- **Injectors**: `inj_*.f90` (e.g., `inj_MYMODEL.f90`)
- **Torque**: `tor_*.f90` (e.g., `tor_MYMODEL.f90`)
- **Two-port**: `twop_*.f90` (e.g., `twop_MYMODEL.f90`)
- **Discrete Control**: `dctl_*.f90` (e.g., `dctl_MYMODEL.f90`)

## Using Your Models

### With PyRAMSES (Python)

**Linux:**
```python
import pyramses

# Initialize simulation with your custom shared library
ram = pyramses.sim('/path/to/your/URAMSES/Release_gnu_l')

# Your models are now available for use in simulations
```

**Windows:**
```python
import pyramses

# Initialize simulation with your custom DLL
ram = pyramses.sim(r'C:\path\to\your\URAMSES\Release_intel_w64')

# Your models are now available for use in simulations
```

### With STEPSS (Java) - Windows Only
```java
// Use ramses.dll with STEPSS Java interface
// Your custom models will be available in STEPSS simulations
```

### Standalone Simulation

**Linux:**
```bash
cd Release_gnu_l
./dynsim
```

**Windows:**
```bash
cd Release_intel_w64
./dynsim.exe
```

## Troubleshooting

### Linux Issues

1. **gfortran not found**
   ```bash
   # Ubuntu/Debian
   sudo apt install gfortran
   ```

2. **OpenBLAS not found**
   ```bash
   # Ubuntu/Debian
   sudo apt install libopenblas-dev
   ```

3. **Module files not found**
   - Ensure `modules_lin/` directory exists and contains `.mod` files
   - Verify `libramses.a` is present in `modules_lin/`

4. **Undefined reference errors**
   - Check that your model subroutine names match those in association files
   - Ensure all dependencies are properly linked
   - Verify that OpenBLAS is properly installed

5. **New model not being compiled**
   - Ensure the model file has a `.f90` extension
   - Check that the file is in the `my_models/` directory
   - Run `make -f Makefile.gfortran clean all` to force a full rebuild
   - Check that your model subroutine names match those in association files
   - Ensure all dependencies are properly linked

### Windows Issues

1. **Compilation Errors**: Ensure Intel Fortran compiler is properly installed and configured
2. **Missing Models**: Verify model names match exactly in association files
3. **DLL Loading**: Check that the path to `ramses.dll` is correct in PyRAMSES
4. **Model Parameters**: Ensure parameter files are properly formatted

### Debug Tips
- Check compiler output for compilation errors
- Verify model subroutine names match exactly in association files
- Test with simple models first before complex implementations
- On Linux, use `ldd Release_gnu_l/ramses.so` to check library dependencies

## Examples

The `my_models/` directory contains several example models:
- `exc_ENTSOE_lim.f90`: ENTSO-E exciter model with limiters
- `exc_GENERIC3.f90`: Generic exciter model type 3
- `exc_GENERIC4.f90`: Generic exciter model type 4
- `exc_ST1A.f90`: IEEE ST1A exciter model
- `inj_AIR_COND1_mod.f90`: Air conditioning load model
- `tor_ENTSOE_simp.f90`: Simplified ENTSO-E torque model

## Platform Comparison

| Feature | Linux | Windows |
|---------|-------|---------|
| Compiler | gfortran | Intel Fortran |
| BLAS Library | OpenBLAS | Intel MKL |
| Build System | Makefile | Visual Studio |
| Output Library | `ramses.so` | `ramses.dll` |
| Output Executable | `dynsim` | `dynsim.exe` |
| Output Directory | `Release_gnu_l/` | `Release_intel_w64/` |
| Module Directory | `modules_lin/` | `modules/` |
| Model Auto-Detection | ✅ Automatic (wildcard) | ❌ Manual (VS project) |

## Documentation

For comprehensive PyRAMSES documentation, visit:
[https://pyramses.sps-lab.org](https://pyramses.sps-lab.org)

## License

This project is licensed under the Academic Public License. See [LICENSE.rst](LICENSE.rst) for details.

## Support

For issues and questions:
- Check the PyRAMSES documentation
- Review example models in `my_models/`
- Ensure all prerequisites are properly installed

## Contributing

When contributing models:
1. Follow the existing naming conventions
2. Include parameter files (`.txt`) for your models
3. Test thoroughly on both Linux and Windows before submission
4. Document any special requirements or dependencies
