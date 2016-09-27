defmodule Jwt.TimeUtils.Mock do

    def get_system_time(), do: Application.get_env(:jwt, :current_time_for_test)

end