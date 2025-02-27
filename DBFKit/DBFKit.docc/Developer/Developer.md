#  Developer Info

I have made this page to note down how I approached reverse engineering DBF files. I will talk about over here how DBF files are written, and everything else necessary to know about DBF files.

To start with, picture the data we write into the file as a table. We are literally writing a table into the file.

## Standard Layout

I would like to devote this section to talk about an important detail about DBF files. I will list down here a table, which you may or may not have seen before, that talks about on what byte all the data goes on. I will then explain what it all means.

| Byte  | Contents | Meaning                               |
| ----- | -------- | ------------------------------------- |
| 0     | 1 byte   | The DBF file version                  |
| 1-3   | 3 bytes  | Date of last update                   |
| 4-7   | 4 bytes  | Number of records                     |
| 8-9   | 2 bytes  | Number of bytes in header             |
| 10-11 | 2 bytes  | Number of bytes in record             |
| 12-13 | 2 bytes  | Reserved                              |
| 14    | 1 byte   | Flag indicating incomplete transation |
| 15    | 1 byte   | Encryption Flag                       |
| 16-27 | 12 bytes | Reserved                              |
| 28    | 1 byte   | Production .mdx flag                  |
| 29    | 1 byte   | Language Driver ID                    |
| 30-31 | 2 bytes  | Reserved                              |
| 32-n  | n        | Column Descriptors                    |
| n + 1 | 1 byte   | Column array terminator               |
| n + 3 | n        | Row info                              |

## Description of Layout

Now lets talk about what it all means. I feel like it is important to mention what the bytes mean.
At first glance, it appears how the bytes mean we refer to specific parts of the file written to (like byte 0 refers to the first character written on the first row and column of the file). This however is _not necessarly the case_!

Amazingly, DBF files are written purely from the computers memory! The bytes refer to where the data is written to in a buffer. And to those of you who don't know what a buffer is, a **buffer is a region of memory used to store data temporarily while it is being moved from one place to another** ([Definition Taken From Wikipedia](https://en.wikipedia.org/wiki/Data_buffer), see this [Stackoverflow](https://stackoverflow.com/questions/648309/what-does-it-mean-by-buffer) for more info)

So looking back at the table, picture this. Byte 0 (the DBF file version) represents byte 0 in the buffer. Bytes 1-3 represent the date of last update in the buffer. And so on.

Eventually, we will be taking this buffer and writing it to a file.

### The first and most important bytes
At byte 0, we should just input the dbf file version we are using simply. This should be a 8 bit integer.

For the next bytes, we are inputting the date of the last time we were updating the file. On byte 1, we input the year of last update. Note that when you get the year, make sure you subtract 1900 from it. For instance, if the year is 2024, we would store into byte 1, 124 (2024 - 1900). I don't know why it is done like this, but this is just how it should be stored. On byte 2, store the month number, and on byte 3, store the day number. Make sure all these numbers are 8 bit.

On bytes 4-7, we simply write the number of records there are. The number of records is equal to the number of rows there are in the table we are writing. This should be a 32 bit integer

On bytes 8-9, we record the number of bytes the columns take up. This should be a 16 bit integer. The number of bytes the column takes up is equal to (32 \* (the number of columns) + 33)

On bytes 10-11, we record the number of bytes the rows take up. This should also be a 16 bit integer. This number is equal to 1 + (the maximum length of each column)

In the next section below, I will talk about how we write down column info. All other information that I did not talk about in the table above is not necessarily important to write to the buffer.

---

## Writing Columns

Looking at the table, we begin writing columns starting at byte 32. Now note that **one column is 32 bytes**. Meaning if you have 2 columns, you will be writing 64 bytes of data in the column descriptor. If you have 3, you will be writing 96 bytes, and so on.

This also signals on what byte each column starts on. The first column will start on byte 32 (and ends on 63), the second will start on byte 64 (and ends on 95), the third will start on byte 96 (and end on 127) and so on.

To get a better idea of what data we are writing, lets look at the following table which shows on what byte we are writing each data. For the sake of simplicity, assume that when we start on byte 0 (in the column table), we mean that we are starting on the byte of the start of a new column

| Byte     | Contents | Meaning              |
| -------- | -------- | -------------------- |
| 0-10     | 11 bytes | Column name          |
| 11       | 1 byte   | Column Type          |
| 12-15    | Reserved | Reserved             |
| 16       | 1 byte   | Column Length        |
| 17       | 1 byte   | Column Decimal Count |
| 18-19    | 2 bytes  | Workd Area ID        |
| 20       | 1 byte   | Reserved             |
| 21-30    | 10 bytes | Reserved             |
| 31       | 1 byte   | Production MDX       |

Now lets discuss the column data. To start with, the first thing we are writing to the buffer is the column name. Even though in the table it says the contents should be 11 bytes, **it does not** have to be exactly 11 bytes. This simply refers to the maximum column name length. It should be no bigger than 11 bytes. Please note that whatever column name we store into the buffer, **all the characters of the column name must be in ASCII**. That does mean that each byte we store the column name must be a ASCII character. Take a look at the table below for an example of how we would store the column name "User"
| Byte  | Content |
| ----- | ------- |
| 0     | 85      |
| 1     | 115     |
| 2     | 101     |
| 3     | 114     |

Note that for the numbers listed in the content column, those are all ASCII codes for each character respectively in "User". For instance, 85 is the character code for "U" and 115 is the character code for "s" and so on. Since we did not use up all 11 bytes, we do not have to fill in anything else from byte 4-10, we can leave it empty as the column name doesn't take up all the space.

On the next byte, we give the column type. Note again that we are still writing these bytes in the buffer, not some kind of string. There are 5 different types of columns we can input. The possible types are given in the table below.
| Column Type | What it is    | What it means                       |
| ----------- | ------------- | ----------------------------------- |
| C           | Character     | Any text (must be in ASCII)         |
| D           | Date          | The date                            |
| F           | Float         | Decimal number                      |
| L           | Boolean       | Any boolean.                        |
| M           | Memo          | Any ASCII text                      |
| N           | Numeric       | Just a number                       |
| I           | Long          | long (number)                       |
| +           | Autoincrement | Same as long                        |
| G           | OLE           | Just holds an index to a memo block |
| B           | Binary        | Same as OLE                         |
| O           | Double        | A double value                      |

For the date, we are passing in some numbers in the format of YYYYMMDD. And for boolean, we are passing in "T" (for true), "F" (for false), or "?" (for uninitialized)

Note that any value passed in should always be in ASCII. Also, it is important to note that DBFKit does not support the field type Memo for both reading and writing. I was never able to understand what the field type meant, and how it is different from Character.

By the way, when giving the column type of character, the values we pass in for our row doesn't necessarily have to be a single character. Character, in DBF files, is simply a fancy way of saying that the values we are passing in are going to be characters (or string rather)

The last important thing worth talking about when filling in column data is the column length. This sets the maximum length allowed to fill in data for a column. All columns must have a set length, regardless if it is of type character or not. This length will also ultimately dictate how many bytes a single element in a row (at the index of the column) will take up. For instance, if the column "User" has a length of 40, the first element in all rows (which we will assume is of type C) should have a character length that does not exceed 40.

The maximum column length allowed is 254. Also, the number should be a 16 bit integer.

---

## Writing the Rows
This is the easiest thing to write! Believe it or not, you begin writing the rows after the array field terminator byte (0x0D). The first byte in a row should determine if the row (or record) is marked as deleted or not. If the row is not deleted, it should be marked with a space (0x0020), else mark it with an asterik (0x2A).

Lets have a look at this example. Assume we have two columns, "User" (which has a max length of 40 and is of type C) and "score" (which has a max length of 2 and is of type N). Lets say we are trying to write the following row with the elements "John" and "22".

We would write it as follows. We start one byte after the terminator. For that byte, we will mark it with a space (0x0020) to mark the record as active. Then we move onto the next byte(s). Then for every character in "John", we would convert it to ASCII, and fill it into the respective byte. So the ASCII code of J would be the first thing we fill in for n + 2 (where n is the byte of where the terminator is), the ASCII code of o would be the next thing we fill in for n + 3 and so on.

But you will notice that "John" doesn't use up the whole 40 character length limit. So what do we fill in with the rest of the 36 bytes? We fill it in with nothing. Once we are done writing the data, we move onto the next item to write.

For the next item to write, which is "22", we must start at the next valid byte. The next valid byte is when the next column would begin, which would be on byte n + 42. (n + 2 for the terminator, and + 40 for the length of the previous column). And the pattern continues for each element in the row.

Once we are done writing a row, and we are ready to start writing the next one, we begin writing it on byte n + 1 (where n is the byte where the previous row ends), and the pattern continues. Remember that the first byte written for any row is the byte that determines if the row is active or not. So on byte n + 1, mark it with a space or asterik, then continue the pattern.

After we have finished writing all the rows, we don't need to do anything more. The very last byte (or the one after the last row) is the eof marker. That is 0x1A.

## Writing Memo Fields

A normal column with type "C" only allows you to store text up to size 254. Memo fields allow you to store larger text. Here is the process of how it works, and how you would write it in the DBF file.

To start with, the length of a memo field (**specifically in a DBF file**) will always be 10 [bytes]. The value stored in these bytes is a number, specifically, an index. Before I explain what this index means, lets talk about DBT files for a moment.

A DBT file _is a memo_ file. In other words, this is where we would store the text in the memo field. Usually, this file has the exact same name as the DBF file (and is in the same directory). The file structure of a DBT file (specifically for dBase version 3) is as follows:

| Byte    | What it is                                    |
|---------|-----------------------------------------------|
|0        |An integer pointing to the next available index|
|1-511    |Nothing (should all be set to "0")             |
|512-1024 |Memo block 1                                   |
|1025-1536|Memo block 2                                   |

I hope you see the pattern here for the file structure. We have the file header which occupies the first 512 bytes. Now picture the above table as a list. The header represents index 0 in that list. Memo block 1 represents element at index 1 in the list, Memo block 2 represents element at index 2 in the list and so on.

Essentially, the value we put in the memo field in the DBF file is a number, which represents the index of the block it points to. Note that none of these indexes should point to index 0, as that is the header of the DBT file. However, please take note of byte 0 in the DBT header. This byte dictates the next available index for writing another memo block. For instance, if we have a DBT file with 2 memo blocks (this excludes the header, so similar to what we have above as the example), byte 0 would be set to the number 3.

The number we put in the memo field (in the DBF file) should be written in the exact same way we write any other value in DBF files.

Okay, now lets talk about how we write the actual data in each of these memo blocks. Note that the data we write into a memo block is the \*real\* (real means the actual text the field holds, which could have text with a size larger than 254) value the memo field holds.

For the first example, lets assume we have a text with a size smaller than 510 (we will say 312). We will also assume that its corresponding memo block index is 1. We would first write down (starting from byte 512) this text like we would write any other text in a DBF file. Once we finish that, we skip all the way to byte 1024 (or the byte that represents the end index of the block) and note down the EOF marker (0x1A) as a terminator for the block.

But what if we had a text larger than 512, what do we do? Thats pretty easy actually! We continue writing to the next block! So if we have a string with length 600 (and we start on block 1), we continue writing to block 2. We don't put any terminators or any sign of the text stops. Once we have written all the bytes, we skip to the end of the block (we finished writing on) and make the last two bytes the EOF markers (to denote the terminators). So in our example, we would put those two EOF markers on bytes 1535 and 1536. Then, we set byte 0 to the value of "3," since the next memo data will begin on block 3.

## Writing/Reading Double/Autoincrement/Long Fields

These are probably the hardest fields to work with. To start with, _double_ fields will always be 8 bytes, and the other two (which by the way are identical) will always be 4 bytes. The character which denotes double fields is "O" while for autoincrement it is "+" and long is "I".

The idea for writing the values of these fields is pretty simple. Please note that just because the long field, for example, will always be 4 bytes in size _doesn't necessarily imply that the character length of a number_ must be 4. The same goes with the other two. So basically, we have to take our integer (or double if the field type is double) and convert it into a 4 byte representation of UInt8 (or 8 for double).

Sounds confusing? Yeah it probably is. So let me try explaning it like this. You take a number, lets say 5, and first you have to convert it into a 32 bit integer (or if double, 64 bit float). You then take that number, and then convert it into an array (or new buffer) of 4 UInt8s (or 8 for double). And all the values in that array, you would write down into the main buffer. And thats how you would write those data types in each record!

That makes reading these values kind of annoying too. But the process is similar. Just take 4 bytes (or 8 for double) at the column index position in the record, put whatever those UInt8 are in an array, and convert all the values in that array into the actual number.

## Writing/Reading Timestamp Fields

Timestamp fields are similar to Date fields. The only difference between the two is that timestamp is supposed to have the ability to include time. Before learning about how to actually write it, lets examine what value it holds.

Timestamp is a field which is 8 bytes at maximum (and yes, all 8 of those bytes are written to, so like with the Long field type, some converting will need to be done). The first 4 bytes represent the date, and the last 4 represent the time. The date is the number of days since January 1 4713 BC. For instance, if you have a date of September 14, 2015, you would need to compute the number of days since January 1 4713 BC to that date first. Then, you would take that number, and convert it into 4 bytes (kind of like with Autoincrement/Long fields, it is the exact same process).

Like I said before, the time takes up the last 4 bytes of data. To store it, first completely convert your time into milliseconds. Yes, you would need to convert your hours, minutes, and seconds into milliseconds. You then take that number, and convert it into 4 bytes (just like with Autoincrement/Long fields).

And thats how Timestamp fields are written! Reading them should therefore not be that challenging either. First, just take the first 4 bytes of data, convert them into a number (which would represent the number of days since January 1 4713 BC), and compute the date given the information you have. That is probably the most challenging part. The last 4 bytes should be extremely easy to convert. All you have to do is convert those last 4 bytes into a number (which would represent your milliseconds), and then convert it all into hours/minutes/seconds.

---

## Conclusion
That is about it for the structure of DBF files and how to read/write them. One of the most important things to note, again, from this section is that we are writing all this data into a buffer (which at one point gets written into a file), not a string.
