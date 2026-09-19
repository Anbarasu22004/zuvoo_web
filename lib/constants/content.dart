/// All site copy and media mapping. Swap placeholders before launch.
class Content {
  // ---- Placeholders ----
  static const founderName = '[Founder Name]';
  static const contactEmail = 'hello@zuvoo.com';
  static const socials = <String, String>{
    // 'LinkedIn': 'https://linkedin.com/company/zuvoo',
    // 'Instagram': 'https://instagram.com/zuvoo',
    // 'X': 'https://x.com/zuvoo',
  };

  // ---- Brand ----
  static const tagline = 'AI for the world beyond the screen.';

  // ---- Hero ----
  static const heroEyebrow = 'Zuvoo  ·  Real-world AI';
  static const heroHeadline =
      'We build AI systems that move beyond the screen and become part of real-world experiences.';
  static const heroSupport = 'Quiet intelligence for the places you shop, travel, work and live.';
  static const heroCta = 'See what we\'re building';

  static const moments = [
    Moment(
      video: 'assets/video/moment_store.mp4',
      poster: 'assets/images/moment_store.jpg',
      place: 'Retail',
      title: 'In the store',
      line: 'Understands what you\'re looking for, right where you\'re looking.',
    ),
    Moment(
      video: 'assets/video/moment_travel.mp4',
      poster: 'assets/images/moment_travel.jpg',
      place: 'Mobility',
      title: 'On the move',
      line: 'Keeps your plans in step while the world rushes past.',
    ),
    Moment(
      video: 'assets/video/moment_nature.mp4',
      poster: 'assets/images/moment_nature.jpg',
      place: 'Wellbeing',
      title: 'In the moment',
      line: 'Notices what matters to you and helps you hold on to it.',
    ),
    Moment(
      video: 'assets/video/moment_home.mp4',
      poster: 'assets/images/moment_home.jpg',
      place: 'Work',
      title: 'At your desk',
      line: 'Handles the small tasks so your attention stays on the big ones.',
    ),
    Moment(
      video: 'assets/video/moment_space.mp4',
      poster: 'assets/images/moment_space.jpg',
      place: 'Spaces',
      title: 'Where you live',
      line: 'Fades into the room, and responds when you need it.',
    ),
  ];

  // ---- What we're building ----
  static const buildTitle = 'What we\'re building';
  static const buildIntro = 'Three capabilities that let AI leave the screen and work in the real world.';
  static const building = [
    BuildItem(
      video: 'assets/video/build_understand.mp4',
      poster: 'assets/images/build_understand.jpg',
      label: '01  Understand',
      title: 'AI that reads context',
      body: 'Systems that grasp language, intent and situation, so help starts from what you mean, not what you type.',
    ),
    BuildItem(
      video: 'assets/video/build_connect.mp4',
      poster: 'assets/images/build_connect.jpg',
      label: '02  Connect',
      title: 'One quiet, shared layer',
      body: 'Intelligence that links devices, places and people, so assistance can follow you through the day.',
    ),
    BuildItem(
      video: 'assets/video/build_act.mp4',
      poster: 'assets/images/build_act.jpg',
      label: '03  Act',
      title: 'Help you can feel',
      body: 'AI that ends in real outcomes: the essentials arranged, the plan made, the moment kept.',
    ),
  ];

  // ---- Products we're focused on ----
  static const productsEyebrow = 'Our products';
  static const productsTitle = 'What we\'re launching first';
  static const productsIntro = 'Three products that bring Zuvoo\'s AI into everyday life.';

  /// Fill in store and website links as each product goes live.
  /// Empty links show a quiet "Coming soon" state instead of a dead button.
  static const projects = [
    Project(
      name: 'My Diary',
      category: 'Personal journaling',
      description: 'A private, calm space to write your day, track how you feel and look back on the moments that shaped you.',
      chips: ['Private by default', 'Mood insights'],
      video: 'assets/video/project_diary.mp4',
      poster: 'assets/images/project_diary.jpg',
      icon: 'assets/images/app_diary.png',
      tint: 0xFF231A12,
      website: '',
      appStore: '',
      playStore: '',
    ),
    Project(
      name: 'Quick Commerce',
      category: 'Everyday essentials',
      description: 'Groceries and daily needs from trusted neighbourhood stores, routed smartly and delivered in minutes.',
      chips: ['Minutes, not hours', 'Local stores'],
      video: 'assets/video/project_commerce.mp4',
      poster: 'assets/images/project_commerce.jpg',
      icon: 'assets/images/app_commerce.png',
      tint: 0xFF071B20,
      website: '',
      appStore: '',
      playStore: '',
    ),
    Project(
      name: 'Shop AI',
      category: 'AI shopping assistant',
      description: 'Snap or describe anything and get the right product, fair prices and similar picks, matched by AI.',
      chips: ['Visual search', 'Smart matches'],
      video: 'assets/video/project_shopping.mp4',
      poster: 'assets/images/project_shopping.jpg',
      icon: 'assets/images/app_shopping.png',
      tint: 0xFF120F24,
      website: '',
      appStore: '',
      playStore: '',
    ),
  ];

  // ---- Beyond the screen (3D story) ----
  static const story = [
    'Most technology still lives behind glass.',
    'We\'re building AI that steps beyond the screen.',
    'Into the places and moments of real life.',
  ];
  static const storyStages = ['On screen', 'Beyond it', 'Real world'];

  // ---- Mission ----
  static const missionTitle = 'Intelligence that fits into life, not the other way around.';
  static const mission =
      'Zuvoo builds AI systems for the real world. They understand context, work quietly in the background '
      'and turn into help you can feel: at home, at work and on the move.';

  // ---- Future ----
  static const futureTitle = 'We\'re not building a single product.\nWe\'re building what comes next.';
  static const futureLines = ['More systems.', 'More places.', 'More possibilities.'];
  static const futureLabels = ['Understand', 'Act'];

  // ---- Closing ----
  static const closingEyebrow = 'Stay close';
  static const closingTitle = 'We\'re just getting started.';
  static const closingBody =
      'AI is moving off the screen and into the world around us. We\'re building for that future, one thoughtful system at a time.';

  // ---- About ----
  static const founderStatement =
      'I started Zuvoo because the most useful technology shouldn\'t need your constant attention. '
      'Today, intelligence is trapped inside apps and screens. We think it belongs in the world: '
      'understanding what\'s around you, helping at the right moment, and staying out of the way the rest of the time. '
      'We are starting small and building to last.';

  static const nameStory = [
    ('Speed', 'The first half of the name comes from velocity. Good systems respond the moment you need them.'),
    ('Openness', 'The second half comes from the sky: open, calm, and always there. Nothing hidden, nothing surprising.'),
  ];

  static const values = [
    ('Simplicity', 'Technology should disappear into the moment, not demand more of it.'),
    ('Trust', 'Your data stays yours. We say what our systems do, and they do what we say.'),
    ('Speed', 'Help that arrives in the moment it\'s needed, not a moment after.'),
  ];

  static const titles = {
    '/': 'Zuvoo | AI beyond the screen',
    '/about': 'About | Zuvoo',
    '/products': 'What we build | Zuvoo',
    '/contact': 'Contact | Zuvoo',
    '/privacy': 'Privacy Policy | Zuvoo',
    '/terms': 'Terms of Service | Zuvoo',
  };
}

class Moment {
  const Moment({required this.video, required this.poster, required this.place, required this.title, required this.line});
  final String video, poster, place, title, line;
}

class BuildItem {
  const BuildItem({required this.video, required this.poster, required this.label, required this.title, required this.body});
  final String video, poster, label, title, body;
}

class Project {
  const Project({
    required this.name,
    required this.category,
    required this.description,
    required this.chips,
    required this.video,
    required this.poster,
    required this.icon,
    required this.tint,
    this.website = '',
    this.appStore = '',
    this.playStore = '',
  });
  final String name, category, description, video, poster, icon, website, appStore, playStore;
  final List<String> chips;
  final int tint;
}
