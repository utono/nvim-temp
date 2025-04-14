-- lua/custom/plugins/vim-kitty.lua

return {
	'fladson/vim-kitty',
	enabled = true,
	lazy = true,
	ft = { 'kitty', 'conf' }, -- Load the plugin for Kitty config files
	config = function()
		-- Add any additional configuration here if needed
		-- For example, you might want to set up custom key mappings or other settings
	end,
}
