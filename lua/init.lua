local voice = "Jamie"
local show_notification = true
local M = {}
local is_talking = false
local say_process = nil

--- Sends the currently selected text in visual mode to the `message` function.
-- If no selection is found, it prints an error message and exits.
function M.selected()
	-- Get the current visual selection
	if vim.fn.mode() ~= "v" and vim.fn.mode() ~= "V" and vim.fn.mode() ~= "\22" then
		if show_notification then
			vim.notify("Warning: Not in visual mode.", vim.log.levels.WARN, { title = "say.nvim" })
		end
		return
	end
	vim.cmd.normal({ vim.fn.mode(), bang = true })
	vim.cmd.normal({ "gv", bang = true })
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
	if start_row == end_row and start_col == end_col then
		if show_notification then
			vim.notify("Warning: No text selected.", vim.log.levels.WARN, { title = "say.nvim" })
		end
		return
	end
	local lines = vim.fn.getline(start_row, end_row)
	-- Handle single-line and multi-line selections
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col + 1, end_col)
	else
		lines[1] = string.sub(lines[1], start_col + 1)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	-- Join and print the selected text
	local selection = table.concat(lines, " ")
	-- Pass the concatenated string to the `message` function
	M.message(selection)
end

-- The message function will take the  massage and send it to the
-- MacOs say command with the selected voice
function M.message(msg)
	if is_talking then
		if show_notification then
			vim.notify("Already speaking", vim.log.levels.WARN, { title = "say.nvim" })
		end
		return
	end
	if vim.fn.executable("say") == 1 then
		is_talking = true
		if show_notification then
			vim.notify("Starting speaking...", vim.log.levels.INFO, { title = "say.nvim" })
		end
		say_process = vim.loop.spawn("say", {
			args = { "-v", voice, "'" .. msg .. "'" },
		}, function(code, signal)
			say_process = nil
			if code ~= 0 then
				if show_notification then
					vim.notify(
						"Error: say command failed with code " .. code .. " and signal " .. signal,
						vim.log.levels.ERROR,
						{ title = "say.nvim" }
					)
				end
				is_talking = false
			else
				if show_notification then
					vim.notify("Done speaking.", vim.log.levels.INFO, { title = "say.nvim" })
				end
				is_talking = false
			end
		end)
	else
		if show_notification then
			vim.notify("Error: say command not found.", vim.log.levels.ERROR, { title = "say.nvim" })
		end
	end
end

function M.stop_speaking()
	if say_process then
		vim.loop.process_kill(say_process, "sigterm") -- Terminate the process
		say_process = nil
		is_talking = false
		if show_notification then
			vim.notify("Speech stopped.", vim.log.levels.INFO, { title = "say.nvim" })
		end
	else
		if show_notification then
			vim.notify("No active speech to stop.", vim.log.levels.WARN, { title = "say.nvim" })
		end
	end
end

function M.get_voices()
	if not M.voices then
		M.voices = {}
		local handle = io.popen('say -v "?"')
		if handle then
			for line in handle:lines() do
				local voice, language = line:match("^(%S.-)%s+([a-z][a-z]_[A-Z][A-Z]).*")
				if voice and language then
					table.insert(M.voices, { name = voice, language = language })
				end
			end
			handle:close()
		end
	end
	return M.voices
end

function M.show_voices_dialog()
	local voices = M.get_voices()
	if not voices or #voices == 0 then
		vim.notify("No voices found.", vim.log.levels.WARN, { title = "say.nvim" })
		return
	end

	-- Prepare entries for Telescope
	local entries = {}
	for _, voice in ipairs(voices) do
		table.insert(entries, {
			display = string.format("%s (%s)", voice.name, voice.language),
			value = voice,
			ordinal = voice.name .. " " .. voice.language,
		})
	end

	-- Use Telescope to display the list
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Available Voices",
			finder = require("telescope.finders").new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry.value,
						display = entry.display,
						ordinal = entry.ordinal,
					}
				end,
			}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
					voice = selection.value.name
					require("telescope.actions").close(prompt_bufnr)
					vim.notify(
						"Selected Voice: " .. selection.value.name .. " (" .. selection.value.language .. ")",
						vim.log.levels.INFO,
						{ title = "say.nvim" }
					)
				end)
				return true
			end,
		})
		:find()
end

--- Configures the module with user-provided options.
-- @param opts table: A table containing configuration options.
--   - voice (string): The voice to use for the `say` command (default: "Alex").
function M.setup(opts)
	if opts.voice then
		voice = opts.voice
	end
	if opts.show_notification ~= nil then
		show_notification = opts.show_notification
	end
	vim.keymap.set({ "v" }, "<C-t>", M.selected, { desc = "Send selected text to message" })
	vim.keymap.set({ "n" }, "<leader>tv", M.show_voices_dialog, { desc = "Get voices" })
	vim.keymap.set({ "n", "v" }, "<S-C-t>", M.stop_speaking, { desc = "Stop speaking" })
	if show_notification then
		vim.notify("say.nvim loaded with voice: " .. voice, vim.log.levels.INFO, { title = "say.nvim" })
	end
end

return M
