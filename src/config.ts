export const SITE = {
  website: "https://www.nkoll.de/",
  author: "Niklas Koll",
  profile: null,
  desc: "My personal homepage and blog",
  title: "Niklas Koll",
  ogImage: "astropaper-og.jpg",
  lightAndDarkMode: true,
  postPerIndex: 4,
  postPerPage: 4,
  scheduledPostMargin: 15 * 60 * 1000, // 15 minutes
  showArchives: false,
  showBackButton: true,
  editPost: {
    enabled: false,
    text: "Edit page",
    url: "https://git.nkoll.de/nk/nkoll.de/_edit/main/",
  },
  dynamicOgImage: false,
  dir: "ltr",
  lang: "en",
  timezone: "Europe/Berlin",
} as const;
