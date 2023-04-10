math.randomseed(os.time())
local config = {
    mappings = {
        n = {
            L = {
                function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
                desc = "Next buffer"
            },
            H = {
                function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
                desc = "Previous buffer"
            },
        },
        t = {
            ["<Esc>"] = { "<C-\\><C-n>", desc = "Normal Mode from Terminal" }
        }
    },
    options = {
        opt = {
            shell = "pwsh.exe",
            shellcmdflag =
            "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
            keywordprg = ":help",
            guifont = "FiraCode NFM:h12"
        },
        g = {
            -- neovide_transparency = 0.5
        }
    },
    lsp = {
        skip_setup = { "rust_analyzer", "clangd" },
        formatting = {
            format_on_save = true,
        },
        setup_handlers = {
            rust_analyzer = function(_, opts)
                require("rust-tools").setup { server = opts }
            end,
            clangd = function(_, opts)
                require("clangd_extensions").setup { server = opts }
            end,
        },
        config = {
            julials = {
                on_new_config = function(new_config, _)
                    local cmd = {
                        "julia",
                        "--history-file=no",
                        "--startup-file=no",
                        "-e",
                        [[
              # Load LanguageServer.jl: attempt to load from ~/.julia/environments/nvim-lspconfig
              # with the regular load path as a fallback
              ls_install_path = joinpath(
                  get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),
                  "environments", "nvim-lspconfig"
              )
              pushfirst!(LOAD_PATH, ls_install_path)
              using LanguageServer
              using StaticLint
              using SymbolServer
              popfirst!(LOAD_PATH)
              depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
              project_path = let
                  dirname(something(
                      ## 1. Finds an explicitly set project (JULIA_PROJECT)
                      Base.load_path_expand((
                          p = get(ENV, "JULIA_PROJECT", nothing);
                          p === nothing ? nothing : isempty(p) ? nothing : p
                      )),
                      ## 2. Look for a Project.toml file in the current working directory,
                      ##    or parent directories, with $HOME as an upper boundary
                      Base.current_project(),
                      ## 3. First entry in the load path
                      get(Base.load_path(), 1, nothing),
                      ## 4. Fallback to default global environment,
                      ##    this is more or less unreachable
                      Base.load_path_expand("@v#.#"),
                  ))
              end
              @info "Running language server" VERSION pwd() project_path depot_path
              server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
              server.runlinter = true
              run(server)
            ]],
                    };
                    new_config.cmd = cmd
                end
            },
            html = {
                filetypes = {
                    "css",
                    "scss",
                    "sass",
                    "postcss",
                    "html",
                },
            },
            clangd = {
                capabilities = {
                    offsetEncoding = "utf-8"
                },
            }
        }
    },
    plugins = {
        {
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup()
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "help", "rust", "python", "julia" },
        },
        {
            "xiyaowong/transparent.nvim",
            lazy = false
        },
        {
            "sainnhe/sonokai",
            init = function() -- init function runs before the plugin is loaded
                -- vim.g.sonokai_style = "maia"
            end,
        },
        {
            "simrat39/rust-tools.nvim",
            after = "mason-lspconfig.nvim",
            config = {
                function()
                    require('rust-tools').setup {
                        server = astronvim.lsp.server_settings "rust_analyzer",
                    }
                end
            },
            lazy = false
        },
        {
            "williamboman/mason-lspconfig",
            after = "mason.nvim",
            ensure_installed = { "rust_analyzer", "rustfmt", "clangd", "sumneko_lua", "julia_lsp", "prettier", "pyright",
                "autopep8" },
        },
        {
            "tanvirtin/monokai.nvim"
        },
        {
            "p00f/clangd_extensions.nvim",
            after = "mason-lspconfig.nvim",
            config = function()
                require("clangd_extensions").setup {
                    server = {
                        capabilities = {
                            offsetEncoding = "utf-8"
                        }
                    }
                }
            end,
            lazy = false
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            enabled = true,
            build =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        {
            "nvim-neo-tree/neo-tree.nvim",
            opts = {
                filesystem = {
                    filtered_items = {
                        visible = true,
                    }
                }
            }
        },
        {
            "goolord/alpha-nvim",
            opts = function(_, opts)
                local headers = {
                    {
                        "           ▄ ▄                   ",
                        "       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
                        "       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
                        "    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
                        "  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
                        "  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
                        "▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
                        "█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
                        "    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
                    },
                    {
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣿⣿⢳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢧⣿⡿⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⣿⡏⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠸⣿⡇⢹⣿⣿⣿⣿⣿⣿⣿⣿⢻⢿⣿⡿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠸⣇⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⠀⢻⡇⠈⢿⣿⣿⣿⣿⣿⣿⣿⣬⣬⣾⠃⣿⣿⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠹⣆⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⢻⡄⠈⢿⣿⣿⣿⣿⣿⣿⡇⣿⣿⠀⢿⣿⡀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⢹⡆⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠈⢷⡀⠈⢿⣿⣿⣿⣿⣿⠀⣿⣿⡀⠈⢿⣷⡀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣘⣉⣸⣿⣿⡄⠀⢿⡄⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⢛⣿⣿⣷⡀⠈⣷⡀⠘⣿⣿⣿⣿⣿⠀⠘⣿⣷⡀⠈⢿⣷⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⡏⣾⡿⠛⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠘⣷⡀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣫⣭⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣧⠀⢹⣧⠀⢹⣿⣿⣿⣿⣧⠀⠘⣿⣷⡀⠈⢿⣧⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣧⠙⢀⣤⣤⡀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⣿⣿⣿⣧⠀⣿⣇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⡾⠟⠋⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⡆⠈⣿⡆⢸⣿⣿⣿⠿⣿⣧⠀⠹⣿⣷⠀⠘⣿⡆⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠸⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⡏⢀⠀⠈⠉⠀⢸⣿⣿⡿⠟⢿⣿⣿⣿⣿⡿⠛⠉⠉⠉⠛⠛⠿⢿⣿⣿⣿⣿⣿⠀⠀⠙⣿⣿⣿⠀⣿⣿⠰⢿⣿⣿⣿⡏⢻⣿⣿⣿⣿⣿⡿⠀⠠⣴⣦⡀⠈⣿⣿⣿⠿⠛⠉⠉⠛⠛⠻⠿⣿⣿⣿⣿⣿⡏⠀⠀⢻⣿⣿⣷⠀⣿⡇⣸⣿⡟⠁⡀⣸⣿⣇⠀⢻⣿⣇⠀⢻⣿⠀⡙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⣷⡀⢻⣿⣿⣿",
                        "⣿⣿⡟⠙⠿⠿⠿⠟⠁⣾⣿⣷⡆⠘⠛⠛⠉⢀⣀⢠⣿⣿⣿⢋⣠⣤⣤⣤⣤⣄⡀⠀⠀⠈⠉⠙⠛⠛⠳⢄⠀⠻⠿⠛⠁⢟⡅⣾⣆⣿⣿⣿⣅⠀⠻⠿⣿⠿⠋⣰⣄⠀⠀⠉⠁⣰⣿⡟⢁⣠⣤⣤⣤⣤⣀⡀⠀⠀⠈⠉⠛⠛⠛⠷⡀⠀⠿⠿⠋⢰⣿⢧⣿⠏⣠⣾⡇⣿⣿⣿⡄⠈⢿⣿⠀⢸⣿⠀⣿⢸⠟⠉⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠋⠁⠀⢀⣀⣀⡀⢹⣧⠀⢿⣿⣿",
                        "⣿⣿⣿⣦⣄⣀⣀⣠⣼⣿⣿⣿⣧⣄⣠⣴⠾⣿⣇⠘⠿⣿⣿⣿⡿⠿⠿⠟⠛⠋⠁⠀⣀⣀⣀⣠⣀⣀⣰⡿⠀⣤⣤⣴⢣⢟⣾⡿⠋⠙⠻⣿⣿⡄⢀⣀⣀⣠⣴⣿⣿⣿⣶⡆⠰⢿⣿⣴⣿⣿⠿⠿⠟⠛⠋⠁⠀⣀⣀⣀⣀⣀⣀⣼⡟⢠⣤⣤⣶⣿⢫⣿⠏⣰⣿⣿⡀⣿⣿⣿⣷⠀⡀⠀⢀⣾⡿⣼⡟⠀⢠⣤⡀⠈⠻⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋⠉⠀⣀⣠⣴⣶⣿⣿⣿⣿⣿⢸⣿⠆⣾⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⣠⣿⣄⠀⠀⠀⠀⠀⠀⢀⣀⣠⣴⣾⣿⣿⣿⣿⣿⣿⡿⠋⢀⣼⣿⣿⡏⣡⣾⣿⣿⣦⣤⣾⣿⡿⢃⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣴⣾⣿⣿⣿⣿⣿⣿⠿⠋⢠⣾⣿⣿⣿⣱⠟⢃⣴⣿⣿⣿⣇⠈⠉⠉⠁⢠⣿⣿⣿⠟⣽⠟⢰⡀⠀⠈⠁⢠⣄⡀⠉⠉⠉⠉⠁⠀⣀⣠⣤⣶⣿⣿⣿⣿⣿⡋⠀⢙⣿⠏⠈⢁⣴⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡋⠀⠉⣻⣿⣿⣿⣿⣿⣿⣿⣷⣽⣻⠿⢿⣿⣿⠿⠟⠋⠁⣀⣴⣿⣿⣿⣿⡇⠹⣿⣿⣿⣿⡿⠟⠋⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣟⡿⠿⣿⣿⣿⠿⠟⠋⠁⣠⣴⣿⣿⣿⣿⣿⣶⣾⣿⣿⣿⣿⣿⣿⣷⣶⣶⡘⠿⠿⠿⠏⠞⢁⣠⣿⣿⣷⣶⣤⣾⣿⣿⣿⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣦⣶⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣤⣀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣷⡀⠀⠈⠁⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
                    },
                    {
                        '          ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆         ',
                        '           ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
                        '                 ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷⠄⠄⠄⠄⠻⠿⢿⣿⣧⣄     ',
                        '                  ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
                        '                 ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
                        '          ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘⠄ ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
                        '         ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
                        '        ⣠⣿⠿⠛⠄⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
                        '        ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇⠄⠛⠻⢷⣄ ',
                        '             ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
                        '              ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
                        [[                               __                ]],
                        [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
                        [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
                        [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
                        [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
                        [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
                    },
                    {
                        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡖⠁⠀⠀⠀⠀⠀⠀⠈⢲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⠀⣼⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣧⠀⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⣸⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣇⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⣿⣿⡇⠀⢀⣀⣤⣤⣤⣤⣀⡀⠀⢸⣿⣿⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣔⢿⡿⠟⠛⠛⠻⢿⡿⣢⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠀⣀⣤⣶⣾⣿⣿⣿⣷⣤⣀⡀⢀⣀⣤⣾⣿⣿⣿⣷⣶⣤⡀⠀⠀⠀⠀ ',
                        '⠀⠀⢠⣾⣿⡿⠿⠿⠿⣿⣿⣿⣿⡿⠏⠻⢿⣿⣿⣿⣿⠿⠿⠿⢿⣿⣷⡀⠀⠀ ',
                        '⠀⢠⡿⠋⠁⠀⠀⢸⣿⡇⠉⠻⣿⠇⠀⠀⠸⣿⡿⠋⢰⣿⡇⠀⠀⠈⠙⢿⡄⠀ ',
                        '⠀⡿⠁⠀⠀⠀⠀⠘⣿⣷⡀⠀⠰⣿⣶⣶⣿⡎⠀⢀⣾⣿⠇⠀⠀⠀⠀⠈⢿⠀ ',
                        '⠀⡇⠀⠀⠀⠀⠀⠀⠹⣿⣷⣄⠀⣿⣿⣿⣿⠀⣠⣾⣿⠏⠀⠀⠀⠀⠀⠀⢸⠀ ',
                        '⠀⠁⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⢇⣿⣿⣿⣿⡸⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠈⠀ ',
                        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ',
                        '⠀⠀⠀⠐⢤⣀⣀⢀⣀⣠⣴⣿⣿⠿⠋⠙⠿⣿⣿⣦⣄⣀⠀⠀⣀⡠⠂⠀⠀⠀ ',
                        '⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠉⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀ ',
                    },
                    {
                        [[=================     ===============     ===============   ========  ========]],
                        [[\\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //]],
                        [[||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||]],
                        [[|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||]],
                        [[||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||]],
                        [[|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||]],
                        [[||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||]],
                        [[|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||]],
                        [[||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||]],
                        [[||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||]],
                        [[||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||]],
                        [[||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||]],
                        [[||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||]],
                        [[||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||]],
                        [[||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||]],
                        [[||.=='    _-'                                                     `' |  /==.||]],
                        [[=='    _-'                        N E O V I M                         \/   `==]],
                        [[\   _-'                                                                `-_   /]],
                        [[ `''                                                                      ``' ]],
                    },
                }
                opts.section.header.val = headers[math.random(#headers)]
            end,
        }
    },
    colorscheme = "sonokai",
    polish = function()
        vim.cmd([[
          let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
          let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
          set shellquote= shellxquote=
        ]])
    end
}

return config
