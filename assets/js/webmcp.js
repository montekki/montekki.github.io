(() => {
  const modelContext = navigator.modelContext || document.modelContext;
  if (!modelContext || typeof modelContext.registerTool !== "function") {
    return;
  }

  const controller = new AbortController();
  window.addEventListener("pagehide", () => controller.abort(), { once: true });

  modelContext.registerTool(
    {
      name: "discover_blog_resources",
      title: "Discover blog resources",
      description:
        "Returns the canonical machine-readable indexes for this read-only cryptography and Rust blog.",
      inputSchema: {
        type: "object",
        properties: {},
        additionalProperties: false,
      },
      annotations: {
        readOnlyHint: true,
        untrustedContentHint: false,
      },
      execute: async () => ({
        llms: new URL("/llms.txt", location.origin).href,
        sitemap: new URL("/sitemap.xml", location.origin).href,
        feed: new URL("/atom.xml", location.origin).href,
        about: new URL("/about/", location.origin).href,
      }),
    },
    { signal: controller.signal },
  );
})();
