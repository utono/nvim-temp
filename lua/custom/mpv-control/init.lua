-- ~/.config/nvim/lua/custom/mpv-control/init.lua
-- Core MPV control helper module

local home = vim.env.HOME

local M = {}

--- Try to detect the MPV socket for ~/Music or ~/rips files.
function M.get_socket()
  local handle = io.popen 'ls /tmp/mpvsocket-* 2>/dev/null'
  if not handle then
    return nil
  end
  for socket_path in handle:read('*a'):gmatch '[^\n]+' do
    local cmd = string.format([[echo '{"command":["get_property","path"]}' | socat - UNIX-CONNECT:%s]], socket_path)
    local out = io.popen(cmd)
    if out then
      local result = out:read '*a'
      out:close()
      if result and result:match '%S' then
        local decoded = vim.fn.json_decode(result)
        local path = decoded and decoded.data
        if path and (path:find(home .. '/Music') or path:find(home .. '/rips')) then
          return socket_path
        end
      end
    end
  end
  return nil
end

--- Send a command to the active MPV instance.
---@param cmd_table table
function M.send(cmd_table)
  local socket = M.get_socket()
  if not socket then
    vim.notify('MPV socket not found for ~/Music or ~/rips', vim.log.levels.WARN)
    return
  end
  local json = vim.fn.json_encode { command = cmd_table }
  vim.fn.jobstart({ 'sh', '-c', string.format("echo '%s' | socat - UNIX-CONNECT:%s", json, socket) }, { detach = true })
end

--- Show current socket path in a notification
function M.info()
  local socket = M.get_socket()
  if socket then
    vim.notify('🎧 MPV socket found: ' .. socket, vim.log.levels.INFO)
  else
    vim.notify('⚠️ MPV socket not found for ~/Music or ~/rips', vim.log.levels.WARN)
  end
end

return M
