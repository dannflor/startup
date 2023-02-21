# startup
CS 260

# Elevator pitch:
TradeWorld is an online game where the player can gather resources, trade, and build a place to call home. You can interact with other players online to trade resources needed to turn your chunk of the world into whatever you want it to be. You can build houses, mansions, farms, mines, and more. The game offers an engaging progression system with tech research, building designs to unlock, and positioning and building strategies.

![Login screen](.github/loginScreen.jpeg)
![Build screen](.github/buildScreen.jpeg)
![Tech screen](.github/techScreen.jpeg)
![Trade screen](.github/tradeScreen.jpeg)

# Key features:
- Secure login
- Fully interactive and persistent map per user
- User to user interaction via item trades
- Reactive tech list view
- Leaderboard (stretch goal)
- Profile pictures served via Gravatar

# Sam's Startup Notes:

## Startup HTML and CSS
We've definitely taken on a very ambitious project. Building out the structure of the page takes about 10% of the work, styling it 30%, and making it responsive under all circumstances is the other 60%. Every element and popup on every page has to be gone over with a fine-tooth comb.

`aspect-ratio` is reeeeallly hard to use with flex and grid. It will totally ignore the container and overflow its bounds. The most frustrating CSS experience I've ever had. Had to use a weird hack with bottom padding and clipping the overflow scrolling to keep the grid square. If whoever is grading this wants to look at the grid on the `game` page and tell me how to keep it square I'm open for feedback.

Serverside templating is nice for repeating elements like the grid cells and trade and tech lists. I'll miss it when we have to switch to React.

We've already written dummy data into the server so that we can send it to the views. Doing it like this is actually *less* work than hardcoding all of the dummy data into the view, and as a bonus it means we have a super headstart on the services assignment as well.

# Sam's notes:

## Merge conflicts
When you make commits from two different locations that modify the same line without merging in the changes beforehand, you have to resolve the conflict manually when the pull fails.

## Simon HTML
I am a little confused why we are using an input element for the score. Shouldn't it be a static div that we update once we introduce functionality?

I think it's interesting that `<thead>` elements automatically center and bold their text. Is there a way to override that in the CSS?

I added `aria-label`s to the buttons so they are accessibility compliant.

## Simon CSS
I'm impressed how we got the unique shape of the simon gizmo using full corner radius on just one of the corners. I didn't realize you could set the corner radius on every corner separately.

I don't like how the sample code uses absolute positioning. It seems like it's pretty much always better to use flex and margins to position elements so they're fully reactive. After I centered the player element, I had to change the sizing of the gizmo so it wasn't overlapping. If I have more time I'd like to come back and try to fix it, my first try messing around with it I wasn't able to fix it and I feel like I might be slighty constrained by the fact that the outer container is a bootstrap element.

I also want to restyle the Simon logo in the top left but it's a bootstrap class. I like the flexibility of tailwind more.

## Simon JS
The sample code used an interesting syntax that we didn't see in any js Wassignments. Prefixig `#` to methods/members in a class makes them private.

Javascript that touches the DOM is VERY brittle once you start moving around/renaming elements. It is making my spidey senses go off, don't couple UI to business logic!

We're also using a global/singleton `Game` object, though I'm not sure how to do this without global scope. What do you do when you want mock something?

## Simon Service
If I were making this my own way I would have the server template the scoreboard html before it serves it rather than fetching it. Templating seems easier to work with than js fiddling with the DOM. I wonder why we aren't learning something like handlebars in this class.

Services are a good step in the direction of decoupling logic from UI.

## Simon DB
I'm not exactly sure what `pm2` is, but I had to add `--update-env` to the bash script to get it to read my new environment vars. It's amazingly robust, it even persisted between reboots.

You introduce a tiny bit of latency by querying from the AtlasDB rather than your local application storage.

## Simon Auth
Very interesting issue with `pm2`. It runs ~~as root~~ with root's path. Root doesn't have nvm, so it uses the node at `/usr/bin/node`. That is node 12. The sample code has an unassuming line `const token = req?.cookies.token;`. This uses optional chaining, which is part of the `ES2020` standard which wasn't fully supported until node 14. That means the app crashes when you try to launch it through `pm2` but behaves fine if you use plain ol' `node index.js` as the `ubuntu` user. Had to remove the optional chaining. Somebody should probably do something to fix this issue though, I'm sure much of the class will be absolutely flummoxed if they run into this.

The easiest fix I could find is running: `sudo env PATH=$PATH:/home/ubuntu/.nvm/versions/node/v18.13.0/bin` and then `pm2 restart --update-env` to make it point at Node 18

## Simon WebSocket
I ran into an error just because I put the wrong case on the one of the files, but it did work on my dev env. I wonder what the difference between them is.

Websocket stuff is pretty hard to test by yourself! You need to use incognito windows but then that messes with your cookie assignment.

## Simon React
Wow this was a big assignment. Reorganizing everything took forever and I felt like the code became a lot less readable. On the plus side, we got to reuse the header and footer components, but I would much rather inject these serverside using a templating language.

I'm a little unclear when a 404 response is handled by the react router vs the node server.

React is pretty hard to debug. You'd need a compelling reason to choose to use it imo.

## Simon PWA
I've read about PWA before but I never understood it until I implemented it myself. The service worker caches the data clientside and it works offline inasmuch and you've made provisions for offline service calls! Magical.

The page was the wrong size for some reason so I had to shrink the min-width in the css to make it fit on mobile screens.

I saw that a request for the `apple-touch-icon` was failing when I turned off the network so I tried caching that as well but it didn't work, probably because the resource is invoked differently in a `<link>` vs a js call.
