## Homepage Elements:

<img src="https://media.discordapp.net/attachments/753920412164816967/1461590158267908263/image.png?ex=696b1b68&is=6969c9e8&hm=6d7b276371084f92e76b50bdf0e226b236963a0f72a73be6c16d48f97a337ba7&=&format=webp&quality=lossless&width=712&height=1512" alt="" width="250">

## On iOS:

- the same layout that is currently there. No changes made to the hero's design
- there should only be the portrait view available, not rotateable on the mobile ios app
- one button that says "scan face" instead of two separate ones
- recent interactions as normal (current implementation)
- a new section "Your Memories" (place placeholder content there for now, store teh compoennt in Features/HomeTab/Components)
- - should contain: first and foremost things that are upcoming in the next month relating to milestones like other people's birthdays and all that stuff
  - and just cherrypicking random memories from the memory store
- tab on the bottom that just shows home and friends (the current setup, nothing needs to change there)
- specifically, keep the hero's current layout intact. It looks perfect the way the proportions are set up

## On iPadOS:

#### Horizontal:

- on the left, a side navigation that expands on the tabs: (and has the option to collapse into the normal tabs as well)
- - the tabs listed as normal (home and friends)
  - underneath them, there is a group under the name of "Quick Items"
  - Quick items include the following items:
  - - favorites (to access all the people the person has favorited)
    - new memory (this will pull up a screen similar to that where the registration happened previously, ask me the implementation details when it comes to this later)
  - then, another group called "Quick Register"
  - under the quick register, the following items:
  - - from photos
    - from camera
  - and then finally at the bottom of this left side navigation, a gear icon with the text "Preferences" next to it
- The homepage should be like this:
- - instead of a single button, have two buttons (One says scan from camera, other says scan from photos)
  - - both the buttons shouldn't take up the entire horizontal space tho, there should be ample of breathing room
  - for the hero, push things a little bit down (by around 100 pixels or so) because in ipados the tabs option is on the top instead of the bottom (as opposed to iphones, which have it at the bottom), but only push content downwards when the side navigation is not open, and the normal tab is on the top
- note, for the buttons in the left navigation that i just told you above, just leave them be with an onclick to a dummy to be implemented page

#### Vertical:

- similar to the ios version because there would be no side navigation on the vertical mode of the ipad
- but, have to push the text "remi" and everythign else down by about 100px to permanently accomodate for the tab bar being on top of the ipad layout
- and also, another difference is that you should have two buttons instead of one, similar to the horizontal layout. But this time you could have them take the entire width of the screen (give or taking the default padding that is being used for the buttons beneath hero right now)
