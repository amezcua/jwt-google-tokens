defmodule Jwt.TimeUtils.Mock do

    def set_time_for_tests(time \\ :os.system_time(:seconds)), do: Application.put_env(:jwt, :current_time_for_test, time)

    def get_system_time(), do: Application.get_env(:jwt, :current_time_for_test)

end