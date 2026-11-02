To generate text images:
1. Open "text_to_generate.txt" in this directory
2a. If you want a simple toggled image, add a single line with no comma anywhere.
2b. If you want multiple values that correspond to one setting, put the name of the setting first, then add commas for each value it can take.

  Since this is confusing sounding, here's an example:
  If you have a setting called "Item Shuffle" that can be "All Items", "Chests & Tablets", or "Key Items Only", the line would be:

  Item Shuffle,All Items,Chests & Tablets,Key Items Only

  This will make 3 images that have the text:
  1. Item Shuffle: All Items
  2. Item Shuffle: Chests & Tablets
  3. Item Shuffle: Key Items

  You could also make three separate lines, but keeping them in one comma separated line like this prevents stretchy blurring in PopTracker.

So, as a complete example, your text file might look like this:

Reveal hidden items
Hide yellow checks
Auto tab
Item Shuffle,Chests & Tablets,All Items

The first three would be simple toggles, and the last one would be an example of 2b.

3. Save "text_to_generate" with your edits, then run "generate_text.py." 
  - You will probably need a pip module that you don't have, in which case you should run 'pip install "Pillow==13.0.0"' or something equivalent to get the latest fancy version.

4. Generated text will be in the "images" folder in this script's directory, which you can then use.
