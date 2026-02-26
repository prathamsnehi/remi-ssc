## Priority

- improve the UI of the face scanning flow that the AI generated&#x20;
- really low quality jpegs are being saved as the profile photo
- improve the quality of the friends page: someone with dementia should easily be able to recognize (not just photo and name but other deets as well. Like a prominent memory also displayed)
- improve the look and feel of the homepage, look mobbin for inspiration ✅
- ensure uniform spacing and typefont (your memories and recent interactions on the homepage looks like a design mess)
- IPAD OPTIMIZATIONS !!!!!!!
- ONBOARDING !!!!!!!!!

## Optimizations

- implement fail-safes during the scanning (so that if face not visible, unclear, yaw, then stop the timer, give error, tell user to do again) ❌ ADD TO LATER TO DO (IT COUNTS AS OPTIMIZATION, BUT IS IMPORTANT)
- figure out what to keep scrollview, and what not to keep scrollview
- in places where the full captured image suits, do that
- - like in the "Your Recent Memories", just put the entire uncropped image, things like that
- and in places where you just need the face (like the recognized face profile in the scan face flow)
- - here, show the cropped mlRect photo
  - and also in the Friends

## Tiny Bugs:

- when there is only one card in the recent memories, enforce the normal padding rather than the custom 20 padding
- when Your Recent Memories is empty, show a placeholder rather than nothing
- cards dot indicator kinda bugged (especially when card doesn't snap incase of only 2 cards on ipads and shi
