using System;
using System.IO;
using System.IO.Pipes;
using System.Threading;
using System.Threading.Tasks;
using OpenTabletDriver.Plugin;
using StreamJsonRpc;

namespace OpenTabletDriver.Desktop.RPC
{
    public class RpcHost<T> where T : class
    {
        private readonly string pipeName;

        public event EventHandler<bool> ConnectionStateChanged;

        public RpcHost(string pipeName)
        {
            this.pipeName = pipeName;
        }

        public async Task Run(T host, CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                var stream = CreateStream();
                try
                {
                    await stream.WaitForConnectionAsync(ct);
                }
                catch (OperationCanceledException) { } // ignore exceptions caused by daemon shutting down

                _ = RespondToRpcRequestAsync(host, stream, ct);
            }
        }

        private async Task RespondToRpcRequestAsync(T host, Stream stream, CancellationToken ct)
        {
            try
            {
                ConnectionStateChanged?.Invoke(this, true);
                using var rpc = JsonRpc.Attach(stream, host);
                await rpc.Completion.WaitAsync(ct);
            }
            catch (TaskCanceledException) { } // ignore exceptions caused by daemon shutting down
            catch (Exception ex)
            {
                Log.Exception(ex);
            }

            ConnectionStateChanged?.Invoke(this, false);
            await stream.DisposeAsync();
        }

        private NamedPipeServerStream CreateStream()
        {
            return new NamedPipeServerStream(
                this.pipeName,
                PipeDirection.InOut,
                NamedPipeServerStream.MaxAllowedServerInstances,
                PipeTransmissionMode.Byte,
                PipeOptions.Asynchronous | PipeOptions.WriteThrough | PipeOptions.CurrentUserOnly
            );
        }
    }
}
