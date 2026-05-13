# =============================================================================
# classify-products.ps1
# Classifies eCommerce product images into a 3-level taxonomy:
#   category / subcategory / type
# Copies files (non-destructive) and generates products.json
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"

# Root directory (where this script lives)
$rootDir = $PSScriptRoot
$outputJsonPath = Join-Path $rootDir "products.json"

# Relative base for image paths in JSON (relative to src/assets/)
$imageBase = "pic/products"

# =============================================================================
# TAXONOMY RULES
# Each rule: [pattern (regex on full filename + parent path), category, subCategory, type, title hint, tags[]]
# Rules are checked top-to-bottom; first match wins.
# Files that don't match any product rule are skipped (background/UI images).
# =============================================================================

$rules = @(
    # ─── FASHION / SHOES / SNEAKERS ────────────────────────────────────────
    @{ pattern="slide-sneakers";       cat="fashion"; sub="shoes"; type="sneakers";     title="Sneakers";              tags=@("sneakers","shoes","fashion") }
    @{ pattern="gray-sneakers";        cat="fashion"; sub="shoes"; type="sneakers";     title="Gray Sneakers";         tags=@("sneakers","gray","shoes") }
    @{ pattern="red-sneakers";         cat="fashion"; sub="shoes"; type="sneakers";     title="Red Sneakers";          tags=@("sneakers","red","shoes") }
    @{ pattern="white-red-sneakers";   cat="fashion"; sub="shoes"; type="sneakers";     title="White Red Sneakers";    tags=@("sneakers","white","red","shoes") }
    @{ pattern="red-black-nike";       cat="fashion"; sub="shoes"; type="sneakers";     title="Red Black Nike Sneakers"; tags=@("sneakers","nike","red","black") }
    @{ pattern="blue-black-left-nike"; cat="fashion"; sub="shoes"; type="sneakers";     title="Blue Black Nike Sneakers"; tags=@("sneakers","nike","blue","black") }
    @{ pattern="navy-blue-and-white-left"; cat="fashion"; sub="shoes"; type="sneakers"; title="Navy Blue White Sneakers"; tags=@("sneakers","navy","white") }
    @{ pattern="pair-of-black-sneakers"; cat="fashion"; sub="shoes"; type="sneakers";  title="Black Sneakers";        tags=@("sneakers","black","shoes") }
    @{ pattern="light-blue-puma";      cat="fashion"; sub="shoes"; type="sneakers";     title="Light Blue Puma Sneakers"; tags=@("sneakers","puma","light-blue") }
    @{ pattern="athletic-shoes";       cat="fashion"; sub="shoes"; type="athletic";     title="Athletic Shoes";        tags=@("athletic","shoes","sport") }
    @{ pattern="running-shoes";        cat="fashion"; sub="shoes"; type="athletic";     title="Running Shoes";         tags=@("running","shoes","sport") }
    @{ pattern="casual-shoes";         cat="fashion"; sub="shoes"; type="casual";       title="Casual Shoes";          tags=@("casual","shoes","fashion") }
    @{ pattern="modal-shoe";           cat="fashion"; sub="shoes"; type="sneakers";     title="Fashion Sneakers";      tags=@("sneakers","shoes","fashion") }
    @{ pattern="men-athletic-shoes-black"; cat="fashion"; sub="shoes"; type="athletic"; title="Men Athletic Shoes Black"; tags=@("athletic","shoes","men","black") }
    @{ pattern="men-athletic-shoes-green"; cat="fashion"; sub="shoes"; type="athletic"; title="Men Athletic Shoes Green"; tags=@("athletic","shoes","men","green") }
    @{ pattern="knit-athletic-sneakers-gray"; cat="fashion"; sub="shoes"; type="sneakers"; title="Knit Athletic Sneakers Gray"; tags=@("sneakers","knit","gray","women") }
    @{ pattern="knit-athletic-sneakers-pink"; cat="fashion"; sub="shoes"; type="sneakers"; title="Knit Athletic Sneakers Pink"; tags=@("sneakers","knit","pink","women") }
    @{ pattern="women-beach-sandals";  cat="fashion"; sub="shoes"; type="sandals";      title="Women Beach Sandals";   tags=@("sandals","beach","women","shoes") }
    @{ pattern="women-knit-ballet-flat-black"; cat="fashion"; sub="shoes"; type="ballet-flats"; title="Women Knit Ballet Flats Black"; tags=@("ballet-flats","women","black") }
    @{ pattern="women-knit-ballet-flat-gray";  cat="fashion"; sub="shoes"; type="ballet-flats"; title="Women Knit Ballet Flats Gray"; tags=@("ballet-flats","women","gray") }
    @{ pattern="women-knit-ballet-flat-leopard"; cat="fashion"; sub="shoes"; type="ballet-flats"; title="Women Knit Ballet Flats Leopard"; tags=@("ballet-flats","women","leopard") }

    # ─── FASHION / MEN ──────────────────────────────────────────────────────
    @{ pattern="adults-plain-cotton-tshirt.*black";    cat="fashion"; sub="men"; type="t-shirts"; title="Plain Cotton T-Shirt Black";       tags=@("t-shirt","cotton","black","men") }
    @{ pattern="adults-plain-cotton-tshirt.*plus";     cat="fashion"; sub="men"; type="t-shirts"; title="Plain Cotton T-Shirt Plus Black";   tags=@("t-shirt","cotton","plus-size","men") }
    @{ pattern="adults-plain-cotton-tshirt.*red";      cat="fashion"; sub="men"; type="t-shirts"; title="Plain Cotton T-Shirt Red";          tags=@("t-shirt","cotton","red","men") }
    @{ pattern="adults-plain-cotton-tshirt.*teal";     cat="fashion"; sub="men"; type="t-shirts"; title="Plain Cotton T-Shirt Teal";         tags=@("t-shirt","cotton","teal","men") }
    @{ pattern="men-golf-polo.*black";  cat="fashion"; sub="men";  type="polo";     title="Men Golf Polo Black";   tags=@("polo","golf","black","men") }
    @{ pattern="men-golf-polo.*blue";   cat="fashion"; sub="men";  type="polo";     title="Men Golf Polo Blue";    tags=@("polo","golf","blue","men") }
    @{ pattern="men-golf-polo.*red";    cat="fashion"; sub="men";  type="polo";     title="Men Golf Polo Red";     tags=@("polo","golf","red","men") }
    @{ pattern="men-chino-pants-beige"; cat="fashion"; sub="men";  type="pants";    title="Men Chino Pants Beige"; tags=@("pants","chino","beige","men") }
    @{ pattern="men-chino-pants-black"; cat="fashion"; sub="men";  type="pants";    title="Men Chino Pants Black"; tags=@("pants","chino","black","men") }
    @{ pattern="men-chino-pants-green"; cat="fashion"; sub="men";  type="pants";    title="Men Chino Pants Green"; tags=@("pants","chino","green","men") }
    @{ pattern="men-slim-fit-summer-shorts-beige"; cat="fashion"; sub="men"; type="shorts"; title="Men Slim Fit Shorts Beige"; tags=@("shorts","slim-fit","beige","men") }
    @{ pattern="men-slim-fit-summer-shorts-black"; cat="fashion"; sub="men"; type="shorts"; title="Men Slim Fit Shorts Black"; tags=@("shorts","slim-fit","black","men") }
    @{ pattern="men-slim-fit-summer-shorts-gray";  cat="fashion"; sub="men"; type="shorts"; title="Men Slim Fit Shorts Gray";  tags=@("shorts","slim-fit","gray","men") }
    @{ pattern="men-cozy-fleece.*black"; cat="fashion"; sub="men"; type="hoodies";  title="Men Fleece Zip Hoodie Black"; tags=@("hoodie","fleece","black","men") }
    @{ pattern="men-cozy-fleece.*red";   cat="fashion"; sub="men"; type="hoodies";  title="Men Fleece Zip Hoodie Red";   tags=@("hoodie","fleece","red","men") }
    @{ pattern="plain-hooded-fleece-sweatshirt-teal";   cat="fashion"; sub="men"; type="hoodies"; title="Hooded Fleece Sweatshirt Teal";   tags=@("hoodie","sweatshirt","teal") }
    @{ pattern="plain-hooded-fleece-sweatshirt-yellow"; cat="fashion"; sub="men"; type="hoodies"; title="Hooded Fleece Sweatshirt Yellow"; tags=@("hoodie","sweatshirt","yellow") }
    @{ pattern="athletic-cotton-socks"; cat="fashion"; sub="men";  type="socks";    title="Athletic Cotton Socks 6-Pairs"; tags=@("socks","athletic","cotton","men") }
    @{ pattern="blazer";               cat="fashion"; sub="men";   type="suits";    title="Men Blazer";                tags=@("blazer","suit","men","formal") }

    # ─── FASHION / WOMEN ────────────────────────────────────────────────────
    @{ pattern="women-french-terry-fleece-jogger-camo"; cat="fashion"; sub="women"; type="joggers"; title="Women Fleece Jogger Camo"; tags=@("joggers","fleece","camo","women") }
    @{ pattern="women-french-terry-fleece-jogger-gray"; cat="fashion"; sub="women"; type="joggers"; title="Women Fleece Jogger Gray"; tags=@("joggers","fleece","gray","women") }
    @{ pattern="women-stretch-popover-hoodie-black"; cat="fashion"; sub="women"; type="hoodies"; title="Women Popover Hoodie Black"; tags=@("hoodie","women","black") }
    @{ pattern="women-stretch-popover-hoodie-blue";  cat="fashion"; sub="women"; type="hoodies"; title="Women Popover Hoodie Blue";  tags=@("hoodie","women","blue") }
    @{ pattern="women-stretch-popover-hoodie-gray";  cat="fashion"; sub="women"; type="hoodies"; title="Women Popover Hoodie Gray";  tags=@("hoodie","women","gray") }
    @{ pattern="women-chiffon-beachwear";  cat="fashion"; sub="women"; type="beachwear"; title="Women Chiffon Beachwear Black"; tags=@("beachwear","chiffon","women","black") }
    @{ pattern="women-chunky-beanie";      cat="fashion"; sub="women"; type="hats";      title="Women Chunky Beanie Gray";      tags=@("beanie","hat","gray","women") }
    @{ pattern="straw-sunhat";             cat="fashion"; sub="women"; type="hats";      title="Straw Sun Hat";                 tags=@("hat","summer","straw","women") }

    # ─── FASHION / ACCESSORIES / SUNGLASSES ─────────────────────────────────
    @{ pattern="men-navigator-sunglasses-brown";  cat="fashion"; sub="accessories"; type="sunglasses"; title="Men Navigator Sunglasses Brown";  tags=@("sunglasses","navigator","brown","men") }
    @{ pattern="men-navigator-sunglasses-silver"; cat="fashion"; sub="accessories"; type="sunglasses"; title="Men Navigator Sunglasses Silver"; tags=@("sunglasses","navigator","silver","men") }
    @{ pattern="round-sunglasses-black"; cat="fashion"; sub="accessories"; type="sunglasses"; title="Round Sunglasses Black"; tags=@("sunglasses","round","black") }
    @{ pattern="round-sunglasses-gold";  cat="fashion"; sub="accessories"; type="sunglasses"; title="Round Sunglasses Gold";  tags=@("sunglasses","round","gold") }
    @{ pattern="glasses\.jpg";           cat="fashion"; sub="accessories"; type="sunglasses"; title="Fashion Sunglasses";     tags=@("sunglasses","fashion","accessories") }
    @{ pattern="glasses\.png";           cat="fashion"; sub="accessories"; type="sunglasses"; title="Fashion Glasses";        tags=@("glasses","fashion","accessories") }
    @{ pattern="glasses2\.png";          cat="fashion"; sub="accessories"; type="sunglasses"; title="Compact Sunglasses";     tags=@("sunglasses","compact","accessories") }
    @{ pattern="object_glasses";         cat="fashion"; sub="accessories"; type="sunglasses"; title="Premium Sunglasses";     tags=@("sunglasses","premium","fashion") }

    # ─── FASHION / ACCESSORIES / BAGS ───────────────────────────────────────
    @{ pattern="backpack";             cat="fashion"; sub="accessories"; type="bags"; title="Backpack";          tags=@("backpack","bag","fashion") }

    # ─── FASHION / ACCESSORIES / WATCHES ────────────────────────────────────
    @{ pattern="object_applewatch";    cat="fashion"; sub="accessories"; type="watches"; title="Apple Watch";         tags=@("smartwatch","apple","watch") }
    @{ pattern="watch_big";            cat="fashion"; sub="accessories"; type="watches"; title="Classic Watch";        tags=@("watch","classic","accessories") }
    @{ pattern="watch_tp";             cat="fashion"; sub="accessories"; type="watches"; title="Fashion Watch";        tags=@("watch","fashion","accessories") }
    @{ pattern="watch-1\.png";         cat="fashion"; sub="accessories"; type="watches"; title="Sport Watch";          tags=@("watch","sport","accessories") }
    @{ pattern="watch-2\.png";         cat="fashion"; sub="accessories"; type="watches"; title="Casual Watch";         tags=@("watch","casual","accessories") }
    @{ pattern="watch-3\.png";         cat="fashion"; sub="accessories"; type="watches"; title="Slim Watch";           tags=@("watch","slim","accessories") }

    # ─── FASHION / ACCESSORIES / EARRINGS ───────────────────────────────────
    @{ pattern="double-elongated-twist-french-wire-earrings"; cat="fashion"; sub="accessories"; type="earrings"; title="French Wire Earrings Gold"; tags=@("earrings","gold","jewelry","women") }
    @{ pattern="sky-flower-stud-earrings"; cat="fashion"; sub="accessories"; type="earrings"; title="Sky Flower Stud Earrings"; tags=@("earrings","stud","flower","women") }

    # ─── FASHION / ACCESSORIES / CAPS ───────────────────────────────────────
    @{ pattern="cap\.jpg";             cat="fashion"; sub="accessories"; type="caps"; title="Fashion Cap";    tags=@("cap","hat","fashion") }
    @{ pattern="cap\.png";             cat="fashion"; sub="accessories"; type="caps"; title="Classic Cap";    tags=@("cap","hat","fashion") }
    @{ pattern="umbrella";             cat="fashion"; sub="accessories"; type="umbrellas"; title="Fashion Umbrella"; tags=@("umbrella","fashion","accessories") }

    # ─── ELECTRONICS / SMARTPHONES ──────────────────────────────────────────
    @{ pattern="phone1";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 1";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone2";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 2";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone3";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 3";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone4";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 4";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone5";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 5";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone6";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 6";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone7";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 7";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone8";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 8";    tags=@("smartphone","android","mobile") }
    @{ pattern="phone9";               cat="electronics"; sub="smartphones"; type="android";    title="Smartphone Model 9";    tags=@("smartphone","android","mobile") }
    @{ pattern="object_iphone";        cat="electronics"; sub="smartphones"; type="iphone";     title="iPhone";                tags=@("iphone","apple","smartphone") }
    @{ pattern="iphone_big";           cat="electronics"; sub="smartphones"; type="iphone";     title="iPhone Model";          tags=@("iphone","apple","smartphone") }
    @{ pattern="iphone_cutout";        cat="electronics"; sub="smartphones"; type="iphone";     title="iPhone Cutout";         tags=@("iphone","apple","smartphone") }

    # ─── ELECTRONICS / LAPTOPS ──────────────────────────────────────────────
    @{ pattern="macbook_gold";         cat="electronics"; sub="laptops"; type="macbook"; title="MacBook Gold";          tags=@("macbook","apple","laptop","gold") }
    @{ pattern="macbook\.png";         cat="electronics"; sub="laptops"; type="macbook"; title="MacBook";               tags=@("macbook","apple","laptop") }
    @{ pattern="macbookpro";           cat="electronics"; sub="laptops"; type="macbook"; title="MacBook Pro";           tags=@("macbook-pro","apple","laptop") }
    @{ pattern="object_macscreen";     cat="electronics"; sub="laptops"; type="desktop"; title="Mac Desktop Screen";    tags=@("mac","apple","desktop","monitor") }

    # ─── ELECTRONICS / HEADPHONES ───────────────────────────────────────────
    @{ pattern="headphones\.png";      cat="electronics"; sub="headphones"; type="over-ear";    title="Premium Headphones";    tags=@("headphones","over-ear","audio") }
    @{ pattern="object_headphones";    cat="electronics"; sub="headphones"; type="over-ear";    title="Premium Over-Ear Headphones"; tags=@("headphones","over-ear","premium","audio") }

    # ─── ELECTRONICS / TABLETS ──────────────────────────────────────────────
    @{ pattern="ipad\.png";            cat="electronics"; sub="tablets"; type="ipad";    title="iPad";                  tags=@("ipad","apple","tablet") }
    @{ pattern="ipad_dark";            cat="electronics"; sub="tablets"; type="ipad";    title="iPad Dark";             tags=@("ipad","apple","tablet","dark") }
    @{ pattern="ipad\.jpg";            cat="electronics"; sub="tablets"; type="ipad";    title="iPad";                  tags=@("ipad","apple","tablet") }

    # ─── ELECTRONICS / CAMERAS ──────────────────────────────────────────────
    @{ pattern="camera";               cat="electronics"; sub="cameras"; type="dslr";    title="Digital Camera";        tags=@("camera","dslr","photography") }

    # ─── ELECTRONICS / GAMING ───────────────────────────────────────────────
    @{ pattern="ps4";                  cat="electronics"; sub="gaming"; type="console";  title="PlayStation 4";         tags=@("ps4","playstation","gaming","console") }
    @{ pattern="ps5";                  cat="electronics"; sub="gaming"; type="console";  title="PlayStation 5";         tags=@("ps5","playstation","gaming","console") }
    @{ pattern="xbox";                 cat="electronics"; sub="gaming"; type="console";  title="Xbox Console";          tags=@("xbox","gaming","console","microsoft") }
    @{ pattern="games\.jpg";           cat="electronics"; sub="gaming"; type="games";    title="Video Games";           tags=@("games","gaming","entertainment") }

    # ─── ELECTRONICS / ACCESSORIES ──────────────────────────────────────────
    @{ pattern="keyboard_apple";       cat="electronics"; sub="accessories"; type="keyboards";  title="Apple Magic Keyboard";  tags=@("keyboard","apple","mac","accessories") }
    @{ pattern="object_macmouse";      cat="electronics"; sub="accessories"; type="mice";       title="Apple Magic Mouse";     tags=@("mouse","apple","mac","accessories") }
    @{ pattern="mouse\.png";           cat="electronics"; sub="accessories"; type="mice";       title="Computer Mouse";        tags=@("mouse","computer","accessories") }
    @{ pattern="usb\.png";             cat="electronics"; sub="accessories"; type="usb";        title="USB Drive";             tags=@("usb","storage","accessories") }
    @{ pattern="tv\.jpg";              cat="electronics"; sub="televisions"; type="led";        title="Smart TV";              tags=@("tv","smart-tv","led","electronics") }
    @{ pattern="notebook\.jpg";        cat="electronics"; sub="laptops";     type="notebook";   title="Notebook Laptop";       tags=@("notebook","laptop","electronics") }
    @{ pattern="ipod";                 cat="electronics"; sub="audio"; type="mp3-player";       title="iPod Music Player";     tags=@("ipod","apple","music","audio") }

    # ─── FOOD / FAST-FOOD ────────────────────────────────────────────────────
    @{ pattern="food1";                cat="food"; sub="fresh-produce"; type="vegetables";      title="Fresh Vegetables";      tags=@("vegetables","fresh","healthy","food") }
    @{ pattern="food2";                cat="food"; sub="fresh-produce"; type="fruits";          title="Fresh Fruits";          tags=@("fruits","fresh","healthy","food") }
    @{ pattern="food3";                cat="food"; sub="fresh-produce"; type="salad";           title="Fresh Salad";           tags=@("salad","fresh","healthy","food") }
    @{ pattern="food4";                cat="food"; sub="fresh-produce"; type="vegetables";      title="Fresh Produce";         tags=@("vegetables","fresh","food") }
    @{ pattern="food5";                cat="food"; sub="beverages"; type="drinks";              title="Beverage";              tags=@("drink","beverage","food") }
    @{ pattern="food6";                cat="food"; sub="fresh-produce"; type="fruits";          title="Fresh Fruit";           tags=@("fruit","fresh","food") }
    @{ pattern="muesli";               cat="food"; sub="breakfast"; type="cereals";             title="Muesli Cereal";         tags=@("muesli","cereal","breakfast","healthy") }
    @{ pattern="object_coffee";        cat="food"; sub="beverages"; type="coffee";              title="Coffee";                tags=@("coffee","beverage","hot-drink") }
    @{ pattern="coffee_cup";           cat="food"; sub="beverages"; type="coffee";              title="Coffee Cup";            tags=@("coffee","cup","beverage") }
    @{ pattern="meal\.png";            cat="food"; sub="meals"; type="prepared";                title="Prepared Meal";         tags=@("meal","food","prepared") }

    # ─── FURNITURE ───────────────────────────────────────────────────────────
    @{ pattern="object_chair";         cat="furniture"; sub="seating"; type="chairs";           title="Premium Chair";         tags=@("chair","seating","furniture","office") }
    @{ pattern="sofa\.jpg";            cat="furniture"; sub="seating"; type="sofas";            title="Living Room Sofa";      tags=@("sofa","living-room","furniture") }
    @{ pattern="hanging-lamp";         cat="furniture"; sub="lighting"; type="pendant-lamps";   title="Hanging Lamp";          tags=@("lamp","hanging","lighting","furniture") }
    @{ pattern="table-lamp";           cat="furniture"; sub="lighting"; type="table-lamps";     title="Table Lamp";            tags=@("lamp","table","lighting") }
    @{ pattern="table\.jpg";           cat="furniture"; sub="tables"; type="dining";            title="Dining Table";          tags=@("table","dining","furniture") }
    @{ pattern="vanity-mirror";        cat="furniture"; sub="bedroom"; type="mirrors";          title="Vanity Mirror Silver";  tags=@("mirror","vanity","bedroom","furniture") }

    # ─── HOME / BEDDING ──────────────────────────────────────────────────────
    @{ pattern="duvet-cover-set-blue-queen";  cat="home"; sub="bedding"; type="duvet-covers"; title="Duvet Cover Set Blue Queen"; tags=@("duvet","bedding","blue","queen") }
    @{ pattern="duvet-cover-set-blue-twin";   cat="home"; sub="bedding"; type="duvet-covers"; title="Duvet Cover Set Blue Twin";  tags=@("duvet","bedding","blue","twin") }
    @{ pattern="duvet-cover-set-red-queen";   cat="home"; sub="bedding"; type="duvet-covers"; title="Duvet Cover Set Red Queen";  tags=@("duvet","bedding","red","queen") }
    @{ pattern="duvet-cover-set-red-twin";    cat="home"; sub="bedding"; type="duvet-covers"; title="Duvet Cover Set Red Twin";   tags=@("duvet","bedding","red","twin") }
    @{ pattern="blackout-curtain.*beige";     cat="home"; sub="bedding"; type="curtains";     title="Blackout Curtain Set Beige"; tags=@("curtains","blackout","beige","bedroom") }
    @{ pattern="blackout-curtains-black";     cat="home"; sub="bedding"; type="curtains";     title="Blackout Curtains Black";    tags=@("curtains","blackout","black","bedroom") }
    @{ pattern="luxury-tower-set-4";          cat="home"; sub="bath"; type="towels";          title="Luxury Towel Set 4-Piece";   tags=@("towels","luxury","bath","4-piece") }
    @{ pattern="luxury-tower-set-6";          cat="home"; sub="bath"; type="towels";          title="Luxury Towel Set 6-Piece";   tags=@("towels","luxury","bath","6-piece") }
    @{ pattern="cotton-bath-towels";          cat="home"; sub="bath"; type="towels";          title="Cotton Bath Towels Teal";    tags=@("towels","cotton","teal","bath") }
    @{ pattern="bathroom-rug";                cat="home"; sub="bath"; type="rugs";            title="Bathroom Rug";               tags=@("rug","bathroom","bath") }

    # ─── HOME / KITCHEN ──────────────────────────────────────────────────────
    @{ pattern="6-piece-non-stick-baking";    cat="home"; sub="kitchen"; type="bakeware";    title="Non-Stick Baking Set 6-Piece"; tags=@("baking","non-stick","kitchen","cookware") }
    @{ pattern="6-piece-white-dinner-plate";  cat="home"; sub="kitchen"; type="dinnerware";  title="White Dinner Plate Set";      tags=@("plates","dinnerware","white","kitchen") }
    @{ pattern="non-stick-cooking-set";       cat="home"; sub="kitchen"; type="cookware";    title="Non-Stick Cooking Set 15-Piece"; tags=@("cookware","non-stick","kitchen","pots") }
    @{ pattern="floral-mixing-bowl";          cat="home"; sub="kitchen"; type="mixing-bowls"; title="Floral Mixing Bowl Set";    tags=@("bowl","mixing","floral","kitchen") }
    @{ pattern="round-airtight-food-storage"; cat="home"; sub="kitchen"; type="storage";     title="Airtight Food Storage Containers"; tags=@("storage","airtight","containers","kitchen") }
    @{ pattern="coffeemaker";                 cat="home"; sub="kitchen"; type="coffee-makers"; title="Coffee Maker with Glass Carafe Black"; tags=@("coffee-maker","kitchen","black","appliance") }
    @{ pattern="countertop-blender";          cat="home"; sub="kitchen"; type="blenders";    title="Countertop Blender 64oz";    tags=@("blender","kitchen","appliance","64oz") }
    @{ pattern="electric-glass.*kettle";      cat="home"; sub="kitchen"; type="kettles";     title="Electric Glass Kettle";      tags=@("kettle","electric","kitchen","glass") }
    @{ pattern="black-2-slot-toaster";        cat="home"; sub="kitchen"; type="toasters";    title="2-Slot Toaster Black";       tags=@("toaster","kitchen","black","appliance") }

    # ─── HOME / CLEANING ─────────────────────────────────────────────────────
    @{ pattern="liquid-laundry-detergent-lavender"; cat="home"; sub="cleaning"; type="laundry"; title="Liquid Laundry Detergent Lavender"; tags=@("detergent","laundry","lavender","cleaning") }
    @{ pattern="liquid-laundry-detergent-plain";    cat="home"; sub="cleaning"; type="laundry"; title="Liquid Laundry Detergent";          tags=@("detergent","laundry","cleaning") }
    @{ pattern="facial-tissue";               cat="home"; sub="cleaning"; type="tissues";     title="Facial Tissue 2-Ply 18-Box";    tags=@("tissue","facial","cleaning","home") }
    @{ pattern="kitchen-paper-towels";        cat="home"; sub="cleaning"; type="paper-towels"; title="Kitchen Paper Towels 30-Pack";  tags=@("paper-towels","kitchen","cleaning") }
    @{ pattern="trash-can.*30-liter";         cat="home"; sub="cleaning"; type="trash-cans";  title="Trash Can 30L with Foot Pedal"; tags=@("trash-can","30L","foot-pedal","cleaning") }
    @{ pattern="trash-can.*50-liter";         cat="home"; sub="cleaning"; type="trash-cans";  title="Trash Can 50L with Foot Pedal"; tags=@("trash-can","50L","foot-pedal","cleaning") }

    # ─── CARS ─────────────────────────────────────────────────────────────────
    @{ pattern="bmw2";                 cat="cars"; sub="luxury"; type="sedan";       title="BMW 2 Series";          tags=@("bmw","sedan","luxury","car") }
    @{ pattern="bmw3";                 cat="cars"; sub="luxury"; type="sedan";       title="BMW 3 Series";          tags=@("bmw","sedan","luxury","car") }
    @{ pattern="bmw6";                 cat="cars"; sub="luxury"; type="coupe";       title="BMW 6 Series";          tags=@("bmw","coupe","luxury","car") }
    @{ pattern="bmw7";                 cat="cars"; sub="luxury"; type="sedan";       title="BMW 7 Series";          tags=@("bmw","sedan","luxury","car") }
    @{ pattern="lambo";                cat="cars"; sub="supercars"; type="coupe";    title="Lamborghini";           tags=@("lamborghini","supercar","exotic","car") }

    # ─── SPORT / BICYCLES ────────────────────────────────────────────────────
    @{ pattern="sport[/\\\\]bikes";    cat="sport"; sub="bicycles"; type="bikes";   title="Sport Bicycle";         tags=@("bicycle","bike","sport","cycling") }

    # ─── SPORT / MOTORCYCLES ─────────────────────────────────────────────────
    @{ pattern="sport[/\\\\]motor";    cat="sport"; sub="motorcycles"; type="motorbike"; title="Motorcycle";       tags=@("motorcycle","motorbike","sport") }

    # ─── SPORT / EQUIPMENT ────────────────────────────────────────────────────
    @{ pattern="intermediate-composite-basketball"; cat="sport"; sub="ball-sports"; type="basketball"; title="Composite Basketball"; tags=@("basketball","sport","ball","intermediate") }

    # ─── MEDICINE ────────────────────────────────────────────────────────────
    @{ pattern="capsule";              cat="medicine"; sub="supplements"; type="capsules"; title="Medicine Capsules";  tags=@("capsule","medicine","supplement","health") }
    @{ pattern="medicine[/\\\\].*1";   cat="medicine"; sub="supplements"; type="pills";   title="Medicine Pills";     tags=@("pills","medicine","supplement","health") }
    @{ pattern="medicine[/\\\\].*2";   cat="medicine"; sub="supplements"; type="tablets"; title="Medicine Tablets";   tags=@("tablets","medicine","supplement","health") }
    @{ pattern="medicine[/\\\\]";      cat="medicine"; sub="supplements"; type="medicine"; title="Medicine Product";  tags=@("medicine","health","supplement") }

    # ─── BOOKS ────────────────────────────────────────────────────────────────
    @{ pattern="educated\.svg";        cat="books"; sub="non-fiction"; type="biography"; title="Educated - Book";   tags=@("book","biography","non-fiction","education") }
    @{ pattern="book[/\\\\]";          cat="books"; sub="general"; type="books";         title="Book";              tags=@("book","reading","general") }
)

# =============================================================================
# HELPER: Convert a raw filename into a title-case label
# =============================================================================
function Get-TitleFromFilename {
    param([string]$filename)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    # Replace hyphens/underscores/dots with spaces, title-case each word
    $name = $name -replace '[_\-\.]', ' '
    $name = $name -replace '\s+', ' '
    $words = $name.Trim() -split ' '
    $titled = ($words | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_.ToLower()) }) -join ' '
    return $titled
}

# =============================================================================
# HELPER: Sanitize a string to kebab-case
# =============================================================================
function To-KebabCase {
    param([string]$s)
    $s = $s.ToLower()
    $s = $s -replace '[^a-z0-9\-\.]', '-'
    $s = $s -replace '-+', '-'
    $s = $s.Trim('-')
    return $s
}

# =============================================================================
# GATHER ALL IMAGE FILES (recursively from rootDir)
# =============================================================================
$imageExtensions = @(".jpg", ".jpeg", ".png", ".webp", ".svg", ".gif")

# Files to skip (common non-product images)
$skipPatterns = @(
    "fashion_bg", "desk_bg", "foodbg", "food1-150", "food2-150", "food3-150",
    "food4-150", "food5-150", "food6-150", "modal-subscribe", "modal-health",
    "form-9", "form-booking", "hero-4", "hero-6", "hero-7", "hero-image",
    "home-img", "page-title", "post2", "grid2", "interior", "office_2",
    "discover1", "showcase-img-2", "about-img", "menu-image", "menu\.jpg",
    "store\.jpg", "blog-", "iphone-wireframe", "map\.png", "athletics\.jpg",
    "gym1", "casual\.jpg", "h2\.jpg", "hero-img", "thumb3", "header_pen",
    "imagegallery", "model2", "new-1", "new-2", "new-3", "new-4", "new-5", "new-6",
    "product-1", "product-2", "product-4", "product-5", "product-6",
    "cart-1", "cart-2", "cart-3", "slide-2", "slide-3",
    "details-1", "details-2", "details-3", "details-4",
    "product-8-1", "product-8-2", "discount",
    "women\.jpg", "men\.jpg", "New folder",
    # Cars sub-files that are logos/bg
    "logo", "footer-bg", "bg\.jpg", "call\.jpg", "page-loader", "categories",
    "revslider", "mega-menu", "moving-car", "hero-slider", "dealers",
    "features", "filter-cars", "360degree", "svg$",
    # Misc
    "bevarage\.svg", "burgers\.svg", "chinese\.svg", "food\.svg",
    "breakfast\.svg", "desserts\.svg", "indian\.svg", "indonesian\.svg",
    "pizza\.svg", "tacos\.svg", "vector-img", "meal\.svg",
    "closer\.jpg", "about-us\.jpg", "recipe",
    "section", "side-bg", "subscribe-bg",
    "icon$", "icons$", "clients$", "mockups$",
    "restaurant\.jpg", "bg \(", "bg\.jpg", "hero\.jpg", "hero1\.jpg",
    "page-title\.jpg", "table-lamp\.jpg", "hanging-lamp\.jpg", "sofa\.jpg", "table\.jpg",
    "section-img", "section-video", "banner", "megamenu", "slider",
    "food\.jpg", "healthy-food", "meal-prep", "diet\.jpg",
    "athletic-cotton-socks" # already caught above, skip redundant
)

Write-Host "`n=== PRODUCT CLASSIFIER ===" -ForegroundColor Cyan
Write-Host "Root: $rootDir" -ForegroundColor Gray

$allFiles = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object {
    $imageExtensions -contains $_.Extension.ToLower()
}

Write-Host "Total image files found: $($allFiles.Count)" -ForegroundColor Yellow

$products = @()
$idCounter = 1
$processedCount = 0
$skippedCount = 0
$copiedCount = 0

foreach ($file in $allFiles) {
    # Build a relative path from rootDir for matching
    $relativePath = $file.FullName.Substring($rootDir.Length).TrimStart('\', '/')
    $relLower = $relativePath.ToLower() -replace '\\', '/'
    $fileName = $file.Name
    $fileNameLower = $fileName.ToLower()

    # Skip known non-product patterns
    $shouldSkip = $false
    foreach ($sp in $skipPatterns) {
        if ($relLower -match $sp.ToLower()) {
            $shouldSkip = $true
            break
        }
    }
    if ($shouldSkip) {
        $skippedCount++
        continue
    }

    # Try to match to a taxonomy rule
    $matched = $null
    foreach ($rule in $rules) {
        $testStr = $relLower
        if ($testStr -match $rule.pattern.ToLower()) {
            $matched = $rule
            break
        }
    }

    # If not matched, skip (probably a UI/asset image)
    if (-not $matched) {
        $skippedCount++
        continue
    }

    $cat  = $matched.cat
    $sub  = $matched.sub
    $type = $matched.type

    # Build clean output filename
    $ext = $file.Extension.ToLower()
    $cleanName = To-KebabCase ($file.BaseName) + $ext

    # Build target directory
    $targetDir = Join-Path $rootDir "$cat\$sub\$type"
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Resolve filename conflicts
    $targetFile = Join-Path $targetDir $cleanName
    if (Test-Path $targetFile) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($cleanName)
        $targetFile = Join-Path $targetDir ($stem + "-$idCounter" + $ext)
        $cleanName  = [System.IO.Path]::GetFileName($targetFile)
    }

    # Copy file
    Copy-Item -Path $file.FullName -Destination $targetFile -Force
    $copiedCount++

    # Determine title
    $title = $matched.title
    if ($title -eq "" -or $title -eq $null) {
        $title = Get-TitleFromFilename $file.Name
    }

    # Build relative image path for JSON (relative to src/assets/)
    $jsonImagePath = "$imageBase/$cat/$sub/$type/$cleanName"

    # Build product entry
    $product = [ordered]@{
        id          = $idCounter
        category    = $cat
        subCategory = $sub
        type        = $type
        image       = $jsonImagePath
        title       = $title
        tags        = $matched.tags
    }

    $products += $product
    $idCounter++
    $processedCount++
}

# De-duplicate: keep only unique image paths
$seen = @{}
$uniqueProducts = @()
$newId = 1
foreach ($p in $products) {
    if (-not $seen.ContainsKey($p.image)) {
        $seen[$p.image] = $true
        $p.id = $newId
        $uniqueProducts += $p
        $newId++
    }
}

# Write JSON
$jsonOutput = $uniqueProducts | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outputJsonPath, $jsonOutput, [System.Text.Encoding]::UTF8)

# Summary
Write-Host "`n=== CLASSIFICATION COMPLETE ===" -ForegroundColor Green
Write-Host "Files scanned:     $($allFiles.Count)" -ForegroundColor White
Write-Host "Products matched:  $processedCount" -ForegroundColor Green
Write-Host "Skipped (UI/BG):   $skippedCount" -ForegroundColor Yellow
Write-Host "Unique in JSON:    $($uniqueProducts.Count)" -ForegroundColor Cyan
Write-Host "Output JSON:       $outputJsonPath" -ForegroundColor Cyan

Write-Host "`nFolder structure created under:" -ForegroundColor White
Get-ChildItem -Path $rootDir -Directory |
    Where-Object { @("fashion","electronics","food","furniture","home","cars","books","sport","medicine") -contains $_.Name } |
    ForEach-Object {
        Write-Host "  $($_.Name)/" -ForegroundColor Magenta
        Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
            Write-Host "    $($_.Name)/" -ForegroundColor DarkMagenta
            Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
                $count = (Get-ChildItem -Path $_.FullName -File).Count
                Write-Host "      $($_.Name)/  ($count files)" -ForegroundColor Gray
            }
        }
    }
