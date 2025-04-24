local voice = "Alex"
local M = {}

--- Sends the currently selected text in visual mode to the `message` function.
-- If no selection is found, it prints an error message and exits.
M.selected = function()
	-- Get the start and end positions of the visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	-- Check if a valid selection exists
	if start_pos[2] == 0 or end_pos[2] == 0 then
		vim.api.nvim_echo({ { "Error: No selection found.", "WarningMsg" } }, true, {})
		return
	end

	-- Retrieve the selected lines and concatenate them into a single string
	local lines = vim.fn.getline(start_pos[2], end_pos[2])
	local selection = table.concat(lines, " ")

	-- Pass the concatenated string to the `message` function
	print("Starting to speak...")
	M.message(selection)
end

-- The message function will take the  massage and send it to the
-- MacOs say command with the selected voice
M.message = function(msg)
	if vim.fn.executable("say") == 1 then
		vim.loop.spawn("say", {
			args = { "-v", voice, msg },
		}, function(code, signal)
			if code ~= 0 then
				print("Error: say command failed with code " .. code .. " and signal " .. signal)
			else
				print("Done speaking.")
			end
		end)
	else
		print(msg)
	end
end

--- Configures the module with user-provided options.
-- @param opts table: A table containing configuration options.
--   - voice (string): The voice to use for the `say` command (default: "Alex").
M.setup = function(opts)
	if opts.voice then
		voice = opts.voice
	end
	vim.keymap.set({ "v", "n" }, "<C-t>", M.selected, { desc = "Send selected text to message" })
	print("Say.nvim loaded with voice: " .. voice)
end

return M
