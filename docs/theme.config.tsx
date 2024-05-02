import { useConfig } from "nextra-theme-docs";

const title = "Ziping's Infra Documentation";
const description = "The documentation for Ziping's IT infrastructure";

export default {
  logo: <span>{title}</span>,
  project: {
    link: "https://github.com/sunziping2016/flakes",
  },
  docsRepositoryBase:
    "https://github.com/sunziping2016/flakes/tree/master/docs",
  useNextSeoProps() {
    // check https://github.com/garmeeh/next-seo#add-seo-to-page
    return {
      titleTemplate: `%s | ${title}`,
    };
  },
  head() {
    const { frontMatter } = useConfig();

    return (
      <>
        <meta property="og:title" content={frontMatter.title || title} />
        <meta
          property="og:description"
          content={frontMatter.description || description}
        />
      </>
    );
  },
  footer: {
    text: <span>MIT {new Date().getFullYear()} © Ziping's Nix Project.</span>,
  },
};
