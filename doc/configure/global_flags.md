<div class="hidden-warning"><a href="https://docs.haskellstack.org/"><img src="https://cdn.jsdelivr.net/gh/commercialhaskell/stack/doc/img/hidden-warning.svg"></a></div>

# Stack's global flags and options

Stack can also be configured by flags and options on the command line. Global
flags and options apply to all of Stack's commands. In addition, all of Stack's
commands accept the `--setup-info-yaml` and `--snapshot-location-base` options
and the `--help` flag.

## `--allow-different-user` flag

Restrictions: POSIX systems only

Default: True, if inside Docker; false otherwise

Enable/disable permitting users other than the owner of the
[Stack root](../topics/stack_root.md) directory to use a Stack installation. For
further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#allow-different-user).

## `--arch` option

Pass the option `--arch <architecture>` to specify the relevant machine
architecture. For further information, see the documentation for the
corresponding non-project specific configuration
[option](yaml/non-project.md#arch).

## `--bash-completion-index` option

Visibility: Hidden

See the [shell auto-completion](../topics/shell_autocompletion.md)
documentation.

## `--bash-completion-script` option

Visibility: Hidden

See the [shell auto-completion](../topics/shell_autocompletion.md)
documentation.

## `--bash-completion-index` option

Visibility: Hidden

See the [shell auto-completion](../topics/shell_autocompletion.md)
documentation.

## `--color` or `-colour` options

Pass the option `stack --color <when>` to specify when to use color in output.
For further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#color).

## `--compiler` option

Pass the option `--compiler <compiler>` to specify the compiler (and,
implicitly, its boot packages). For further information, see the
[`compiler`](yaml/non-project.md#compiler) non-project specific configuration
option documentation.

## `--custom-preprocessor-extensions` option

Pass the option `--custom-preprocessor-extensions <extension>` to specify an
extension used for a custom preprocessor. For further information, see the
documentation for the corresponding project specific configuration
[option](yaml/project.md#custom-preprocessor-extensions).

## `--docker*` flags and options

Stack supports automatically performing builds inside a Docker container. For
further information see `stack --docker-help` or the
[Docker integration](../topics/docker_integration.md) documentation.

## `--[no-]dump-logs` flag

Default: Dump warning logs

Enables/disables the dumping of the build output logs for project packages to
the console. For further information, see the documentation for the
corresponding non-project specific configuration
[option](yaml/non-project.md#dump-logs).

## `--extra-include-dirs` option

Pass the option `--extra-include-dirs <director>` to specify an extra directory
to check for C header files. The option can be specified multiple times. For
further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#extra-include-dirs).

## `--extra-lib-dirs` option

Pass the option `--extra-lib-dirs <director>` to specify an extra directory
to check for libraries. The option can be specified multiple times. For further
information, see the documentation for the corresponding non-project specific
configuration [option](yaml/non-project.md#extra-lib-dirs).

## `--fish-completion-script` option

Visibility: Hidden

See the [shell auto-completion](../topics/shell_autocompletion.md)
documentation.

## `--ghc-build` option

Pass the option `--ghc-build <build>` to specify the relevant specialised GHC
build. For further information, see the documentation for the corresponding
non-project specific configuration [option](yaml/non-project.md#ghc-build).

## `--ghc-variant` option

Pass the option `--ghc-variant <variant>` to specify the relevant GHC variant.
For further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#ghc-variant).

## `--help` or `-h` flags

Pass the `--help` (or `-h`) flag to cause Stack to list its commands and flags
and options common to those commands. Alternatively, command

~~~text
stack
~~~

for the same information.

## `--[no-]hpack-force` flag

[:octicons-tag-24: 3.1.1](https://github.com/commercialhaskell/stack/releases/tag/v3.1.1)

Default: Disabled

By default, Hpack 0.20.0 or later will decline to overwrite a Cabal file that
has been modified manually. Pass the flag `--hpack-force` to allow Hpack to
overwrite such a Cabal file.

## `--hpack-numeric-version` flag

Pass the flag `--hpack-numeric-version` to cause Stack to report the numeric
version of its built-in Hpack library to the standard output stream (e.g.
`0.35.0`) and quit.

## `--[no-]install-ghc` flag

Default: Enabled

Enables/disables the download and installation of GHC when necessary. On
Windows, `--no-install-ghc` also disables the download and installation of the
Stack-supplied MSYS2 when necessary. For further information, see the
documentation for the corresponding non-project specific configuration
[option](yaml/non-project.md#install-ghc).

## `--[no-]install-msys` flag

[:octicons-tag-24: 3.5.1](https://github.com/commercialhaskell/stack/releases/tag/v3.5.1)

Restrictions: Windows systems only

Default: Same as the [`install-ghc`](yaml/non-project.md#install-ghc) setting
(including if that is set on the command line)

If Stack is checking for the Stack-supplied MSYS2 when Stack is setting up the
environment, enables/disables the download and installation of MSYS2 when
necessary. For further information, see the documentation for the corresponding
non-project specific configuration [option](yaml/non-project.md#install-msys).

To skip entirely checking for the Stack-supplied MSYS2, see the documentation
for the [`skip-msys`](yaml/non-project.md#skip-msys) configuration option.

## `--jobs` or `-j` option

Pass the option `--jobs <number_of_jobs>` to specify the number of concurrent
jobs (Stack actions during building) to run.

When [building GHC from source](yaml/non-project.md#building-ghc-from-source),
specifies the `-j[<n>]` flag of GHC's Hadrian build system.

By default, Stack specifies a number of concurrent jobs equal to the number of
CPUs (cores) that the machine has. In some circumstances, that default can cause
some machines to run out of memory during building. If those circumstances
arise, specify `--jobs 1`.

This configuration option is distinct from GHC's own `-j[<n>]` flag, which
relates to parallel compilation of modules within a package.

For further information, see the documentation for the corresponding non-project
specific configuration option: [`jobs`](yaml/non-project.md#jobs).

## `--local-bin-path` option

Pass the option `--local-bin-path <directory>` to set the target directory for
[`stack build --copy-bins`](../commands/build_command.md#-no-copy-bins-flag) and
`stack install`. An absolute or relative path can be specified. A relative path
at the command line is always assumed to be relative to the current directory.

For further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#local-bin-path).

## `--lock-file` option

Default: `read-write`, if snapshot specified in the project-level configuration
file; `read-only`, if a different snapshot is specified on the command line.

Pass the option `--lock-file <mode>` to specify how Stack interacts with lock
files. Valid modes are:

* `error-on-write`: Stack reports an error, rather than write a lock file;
* `ignore`: Stack ignores lock files;
* `read-only`: Stack only reads lock files; and
* `read-write`: Stack reads and writes lock files.

## `--[no-]modify-code-page` flag

Restrictions: Windows systems only

Default: Enabled

Enables/disables setting the codepage to support UTF-8. For further information,
see the documentation for the corresponding non-project specific configuration
[option](yaml/non-project.md#modify-code-page).

## `--nix*` flags and options

Stack can be configured to integrate with Nix. For further information, see
`stack --nix-help` or the [Nix integration](../topics/nix_integration.md)
documentation.

## `--numeric-version` flag

Pass the flag `--numeric-version` to cause Stack to report its numeric version
to the standard output stream (e.g. `2.9.1`) and quit.

## `--[no-]plan-in-log` flag

[:octicons-tag-24: 2.13.1](https://github.com/commercialhaskell/stack/releases/tag/v2.13.1)

Default: Disabled

Enables/disables the logging of build plan construction in debug output.
Information about the build plan construction can be lengthy. If you do not need
it, it is best omitted from the debug output.

## `--resolver` option

A synonym for the [`--snapshot` option](#-snapshot-option) to specify the
snapshot resolver.

## `--[no-]rsl-in-log` flag

[:octicons-tag-24: 2.9.1](https://github.com/commercialhaskell/stack/releases/tag/v2.9.1)

Default: Disabled

Enables/disables the logging of the raw snapshot layer (rsl) in debug output.
Information about the raw snapshot layer can be lengthy. If you do not need it,
it is best omitted from the debug output.

## `--[no-]script-no-run-compile` flag

Default: Disabled

Enables/disables the use of options `--no-run --compile` with the
[`stack script` command](../commands/script_command.md).

## `--silent` flag

Equivalent to the `--verbosity silent` option.

## `--[no-]skip-ghc-check` option

Default: Disabled

Enables/disables the skipping of checking the GHC version and architecture. For
further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#skip-ghc-check).

## `--[no-]skip-msys` option

Restrictions: Windows systems only

Default: Disabled

Enables/disables the skipping of checking for the Stack-supplied MSYS2 (and
installing that MSYS2, if it is not installed) when Stack is setting up the
environment. For further information, see the documentation for the
corresponding non-project specific configuration
[option](yaml/non-project.md#skip-msys).

To prevent installation of MSYS2, if it is not installed, see the documentation
for the [`install-msys`](yaml/non-project.md#install-msys) configuration option.

## `--snapshot` option

[:octicons-tag-24: 2.15.1](https://github.com/commercialhaskell/stack/releases/tag/v2.15.1)

Pass the option `--snapshot <snapshot>` to specify the snapshot. For further
information, see the [`snapshot`](yaml/project.md#snapshot) project-specific
configuration option documentation.

At the command line (only):

*   `--snapshot lts-<major_version>` specifies the latest Stackage LTS Haskell
    snapshot with the specified major version;
*   `--snapshot lts` specifies, from those with the greatest major version, the
    latest Stackage LTS Haskell snapshot;
*   `--snapshot nightly` specifies the most recent Stackage Nightly snapshot;
    and
*   `--snapshot global` specifies the snapshot specified by the project-level
    configuration file in the `global-project` directory in the
    [Stack root](../topics/stack_root.md#global-project-directory).

## `--stack-colors` or `--stack-colours` options

Pass the option `--stack-colors <styles>` to specify Stack's output styles. For
further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#stack-colors).

## `--stack-root` option

Overrides: `STACK_ROOT` environment variable

Pass the option `--stack-root <absolute_path_to_the_Stack_root>` to specify the
path to the [Stack root](../topics/stack_root.md) directory. The path must be an
absolute one.

## `--stack-yaml` option

Default: `stack.yaml`

Overrides: `STACK_YAML` enviroment variable

Pass the option `--stack-yaml <file>` to specify Stack's project-level YAML
configuration file.

## `--[no-]system-ghc` flag

Default: Disabled

Enables/disables the use of a GHC executable on the PATH, if one is available
and its version matches.

## `--[no-]terminal` flag

Default: Stack is running in a terminal (as detected)

Enables/disables whether Stack is running in a terminal.

## `--terminal-width` option

Default: the terminal width (if detected); otherwise `100`

Pass the option `--terminal-width <width>` to specify the width of the terminal,
used by Stack's pretty printed messages.

## `--[no-]time-in-logs` flag

Default: Enabled

Enables/disables the inclusion of time stamps against logging entries when the
verbosity level is 'debug'.

## `--verbose` or `-v` flags

Equivalent to the `--verbosity debug` option.

## `--verbosity` option

Default: `info`

Pass the option `--verbosity <log_level>` to specify the level for logging.
Possible levels are `silent`, `error`, `warn`, `info` and `debug`, in order of
increasing amounts of information provided by logging.

## `--version` flag

Pass the flag `--version` to cause Stack to report its version to standard
output and quit. For versions that are release candidates, the report will list
the dependencies that Stack has been compiled with.

## `--with-gcc` option

Pass the option `--with-gcc <path_to_gcc>` to specify use of a GCC executable.
For further information, see the documentation for the corresponding non-project
specific configuration [option](yaml/non-project.md#with-gcc).

## `--with-hpack` option

Pass the option `--with-hpack <hpack>` to specify use of an Hpack executable.
For further information, see the documentation for the corresponding
non-project specific configuration [option](yaml/non-project.md#with-hpack).

## `--work-dir` option

Default: `.stack-work`

Overrides: [`STACK_WORK`](environment_variables.md#stack_work) environment
variable, and [`work-dir`](yaml/non-project.md#work-dir) non-project specific
configuration option.

Pass the option `--work-dir <relative_path_to_the_Stack_root>` to specify the
path to Stack's work directory, within a local project or package directory. The
path must be a relative one, relative to the the root directory of the project
or package. The relative path cannot include a `..` (parent directory)
component.

## `--zsh-completion-script` option

Visibility: Hidden

See the [shell auto-completion](../topics/shell_autocompletion.md)
documentation.

## `--setup-info-yaml` command option

Default: `https://raw.githubusercontent.com/commercialhaskell/stackage-content/master/stack/stack-setup-2.yaml`

The `--setup-info-yaml <url>` command option specifies the location of a
`setup-info` dictionary. The option can be specified multiple times.

## `--snapshot-location-base` command option

Default: `https://raw.githubusercontent.com/commercialhaskell/stackage-snapshots/master`

The `--snapshot-location-base <url>` command option specifies the base location
of snapshots. For further information, see the documentation for the
corresponding non-project specific configuration
[option](yaml/non-project.md#snapshot-location-base).

## `--help` or `-h` command flags

If Stack is passed the `--help` (or `-h`) command flag, it will output help for
the command.
