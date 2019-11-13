
defmodule Broadway.Telemetry do
   @moduledoc """
   A Commanded middleware to instrument the command dispatch pipeline with
   `:telemetry` events.
   It produces the following three events:
     - `[:broadway, :message, :consumer_receipt, :success]`
   """
 
   defmodule Pipeline do
    defstruct [
     :message,
     :metadata,
     assigns: %{},
    ]
   end


   alias Broadway.Message
   alias Broadway.Telemetry.Pipeline

 
   def consumer_receipt(%Pipeline{} = pipeline) do
     %Pipeline{message: message, metadata: metadata} = pipeline
 
     :telemetry.execute(
      [:broadway, :message, :consumer_receipt, :success],
       %{time: System.system_time()},
       %{message: message, metadata: metadata}
     )
 
     assign(pipeline, :event_time, monotonic_time())
   end
 
  #  def after_dispatch(%Pipeline{} = pipeline) do
  #    %Pipeline{message: message, metadata: metadata} = pipeline
 
  #    :telemetry.execute(
  #      [:broadway, :message, :dispatch, :success],
  #      %{duration: duration(pipeline)},
  #      %{message: message, metadata: metadata}
  #    )
 
  #    pipeline
  #  end
 
  #  def after_failure(%Pipeline{} = pipeline) do
  #    %Pipeline{message: message, metadata: metadata} = pipeline
 
  #    :telemetry.execute(
  #      [:broadway, :message, :dispatch, :failure],
  #      %{duration: duration(pipeline)},
  #      %{message: message, metadata: metadata}
  #    )
 
  #    pipeline
  #  end
 
   # Calculate the duration, in microseconds, between start time and now.
   
   defp duration(%Pipeline{assigns: %{event_time: event_time}}) do
     monotonic_time() - event_time
   end
 
   defp duration(%Pipeline{}), do: nil
 
   defp monotonic_time, do: System.monotonic_time(:microsecond)

   defp assign(%Pipeline{} = pipeline, key, value) when is_atom(key) do
    %Pipeline{assigns: assigns} = pipeline

    %Pipeline{pipeline | assigns: Map.put(assigns, key, value)}
   end
 end