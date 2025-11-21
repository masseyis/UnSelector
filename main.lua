-- AutoClearSelection main.lua
-- Automatically clears pattern selections when the cursor moves outside selection bounds

local rs = renoise.song

------------------------------------------------------------
-- State tracking
------------------------------------------------------------

local last_line = nil
local last_track = nil
local last_column = nil

-- Track selection bounds to detect if selection is being actively modified
local last_selection_start_line = nil
local last_selection_end_line = nil
local last_selection_start_track = nil
local last_selection_end_track = nil

------------------------------------------------------------
-- Selection bounds checking
------------------------------------------------------------

local function is_cursor_within_selection()
	local song = rs()
	local sel = song.selection_in_pattern

	-- No selection means nothing to check
	if not sel then
		return false
	end

	-- Get current cursor position
	local cursor_line = song.selected_line_index
	local cursor_track = song.selected_track_index
	local cursor_column = song.selected_note_column_index

	-- Check line bounds
	if cursor_line < sel.start_line or cursor_line > sel.end_line then
		return false
	end

	-- Check track bounds (if specified in selection)
	if sel.start_track and sel.end_track then
		if cursor_track < sel.start_track or cursor_track > sel.end_track then
			return false
		end
	end

	-- Check column bounds (if specified in selection)
	if sel.start_column and sel.end_column then
		if cursor_column < sel.start_column or cursor_column > sel.end_column then
			return false
		end
	end

	return true
end

------------------------------------------------------------
-- Idle handler (polls cursor position)
------------------------------------------------------------

local function check_cursor_position()
	local song = rs()
	local sel = song.selection_in_pattern

	-- Only proceed if there's a selection
	if not sel then
		-- Reset selection tracking when no selection exists
		last_selection_start_line = nil
		last_selection_end_line = nil
		last_selection_start_track = nil
		last_selection_end_track = nil
		return
	end

	-- Get current cursor position
	local current_line = song.selected_line_index
	local current_track = song.selected_track_index
	local current_column = song.selected_note_column_index

	-- Check if selection bounds are changing (user is actively creating/modifying selection)
	local selection_is_changing = (
		sel.start_line ~= last_selection_start_line or
		sel.end_line ~= last_selection_end_line or
		sel.start_track ~= last_selection_start_track or
		sel.end_track ~= last_selection_end_track
	)

	-- Update selection bounds tracking
	last_selection_start_line = sel.start_line
	last_selection_end_line = sel.end_line
	last_selection_start_track = sel.start_track
	last_selection_end_track = sel.end_track

	-- Don't clear selection if it's actively being modified
	if selection_is_changing then
		-- Update cursor position tracking and return
		last_line = current_line
		last_track = current_track
		last_column = current_column
		return
	end

	-- Check if cursor has moved
	if current_line ~= last_line or current_track ~= last_track or current_column ~= last_column then
		-- Update last known position
		last_line = current_line
		last_track = current_track
		last_column = current_column

		-- Check if cursor is outside selection bounds (and selection is stable)
		if not is_cursor_within_selection() then
			song.selection_in_pattern = nil
		end
	end
end

------------------------------------------------------------
-- Setup
------------------------------------------------------------

-- Attach to idle notifier to poll cursor position
renoise.tool().app_idle_observable:add_notifier(check_cursor_position)
