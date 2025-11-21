-- AutoClearSelection main.lua
-- Automatically clears pattern selections when the cursor moves outside selection bounds

local rs = renoise.song

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

local function clear_selection_if_outside()
	local song = rs()

	-- Only act if there's a selection
	if not song.selection_in_pattern then
		return
	end

	-- Check if cursor is outside selection bounds
	if not is_cursor_within_selection() then
		song.selection_in_pattern = nil
	end
end

------------------------------------------------------------
-- Notifier setup
------------------------------------------------------------

local function attach_notifiers()
	local song = rs()

	-- Attach to cursor position changes
	if not song.selected_line_index_observable:has_notifier(clear_selection_if_outside) then
		song.selected_line_index_observable:add_notifier(clear_selection_if_outside)
	end

	if not song.selected_track_index_observable:has_notifier(clear_selection_if_outside) then
		song.selected_track_index_observable:add_notifier(clear_selection_if_outside)
	end

	if not song.selected_note_column_index_observable:has_notifier(clear_selection_if_outside) then
		song.selected_note_column_index_observable:add_notifier(clear_selection_if_outside)
	end
end

------------------------------------------------------------
-- Song change handling
------------------------------------------------------------

-- When a new song is loaded, we need to re-attach notifiers
local function song_loaded()
	attach_notifiers()
end

-- Initial setup for current song
attach_notifiers()

-- Setup notifier for new song loads
renoise.tool().app_new_document_observable:add_notifier(song_loaded)
