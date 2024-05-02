import nextra from "nextra";

const firstPage = "/designs";

const withNextra = nextra({
  theme: "nextra-theme-docs",
  themeConfig: "./theme.config.tsx",
  latex: true,
  flexsearch: {
    codeblocks: false,
  },
  defaultShowCopyCode: true,
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  redirects: () => [
    {
      source: "/",
      destination: firstPage,
      permanent: false,
    },
  ],
};

export default withNextra(nextConfig);
