import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";

import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { Providers } from "$contexts/Providers";

import wagmiConfig from "./wagmi.config";
import { Provider } from "react-redux";
import { store } from "$store/store";

const queryClient = new QueryClient();

const container = document.getElementById("root");
const root = createRoot(container!);
root.render(
  <React.StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <Provider store={store}>
          <Providers>
            <App />
          </Providers>
        </Provider>
        <ReactQueryDevtools />
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>
);
