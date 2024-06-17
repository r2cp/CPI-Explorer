# CPI Explorer

## Installation

### Instantiate the packages

The `Manifest.toml` file is committed to the repo to allow replicating the exact branches.
You need to add the registry `RegistryDIE` to the Julia installation. 

```julia-repl
julia> ]
pkg> registry add https://github.com/DIE-BG/RegistryDIE 
pkg> instantiate
```

### Running the app

```julia-repl
$ cd to/this/apps/directory
$ julia --project=.

julia> using GenieFramework
julia> Genie.loadapp()
julia> up()
```
