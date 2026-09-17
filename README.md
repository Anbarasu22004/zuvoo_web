# Zuvoo — Flutter Web

    flutter pub get
    flutter run -d chrome
    flutter build web --release        # → build/web

## Home
    Hero        your "journey through modern life" film + statement
                + auto-advancing, swipeable carousel of five real-life moments
    Building    Understand / Connect / Act — each card has its own film
    Products    My Diary, Quick Commerce, Shop AI — film cards with website, App Store and Google Play links
    Story       pinned 3D scene: points form a screen → break out of it → settle into a
                globe with warm "places" linked by arcs (screen → beyond → real world)
    Mission     one statement
    Future      branching paths
    Closing     join form over the sunset still

## Assets (each used once)
    video/hero_journey.mp4      full film, watermark removed, soft loop fade
    video/moment_store|travel|nature|home|space.mp4   scenes cut from the film, seamless boomerang loops
    video/build_understand|connect|act.mp4             rendered films for the capability cards
    video/project_diary.mp4     pen writing in a journal, morning window light
    video/project_commerce.mp4  delivery routes lighting up a night city map from a local store
    video/project_shopping.mp4  AI scans a bag, sneaker and watch and surfaces matching picks
    images/app_*.png            app icons for the three products
    images/*.jpg                matching posters; closing_sunset + about_journey stills

## Performance
- Sections render in a lazy sliver list: off-screen sections aren't built or painted
- Mouse wheel is eased (no stepped scrolling); touch keeps native physics
- Scroll-driven effects use ValueNotifiers — only the animated leaf repaints, never the page
- Carousel slides with CSS transforms on the compositor; Flutter only handles input
- No backdrop blur over video; the 3D scene is ~6 draw calls per frame

## Hosting
    Nginx:  location / { try_files $uri $uri/ /index.html; }

## Product links
Fill `website`, `appStore`, `playStore` for each project in lib/constants/content.dart.
Empty links show "Coming soon"; an empty website turns the main button into "Join the waitlist".
# zuvoo_web
