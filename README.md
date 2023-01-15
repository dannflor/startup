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

# Sam's notes:

## Merge conflicts
When you make commits from two different locations that modify the same line without merging in the changes beforehand, you have to resolve the conflict manually when the pull fails.

## Simon HTML
I am a little confused why we are using an input element for the score. Shouldn't it be a static div that we update once we introduce functionality?

I think it's interesting that `<thead>` elements automatically center and bold their text. Is there a way to override that in the CSS?

I added `aria-label`s to the buttons so they are accessibility compliant.
