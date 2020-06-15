defmodule Jwt.TimeUtils do
  def get_system_time(), do: :os.system_time(:seconds)
end
