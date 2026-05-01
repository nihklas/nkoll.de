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
  showArchives: true,
  showBackButton: true,
  editPost: {
    enabled: false,
  },
  dynamicOgImage: true,
  dir: "ltr",
  lang: "en",
  timezone: "Europe/Berlin",
} as const;
