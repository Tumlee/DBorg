//This file contains various utilty classes
//that are used by the DBorg class.
public import std.algorithm;
public import std.range;
public import std.string;
public import std.ascii;
public import std.conv;

//=============================================
//A class that represents an instance of a word
//in a particular sentence.
//=============================================
class Context
{
    string[] sentence;
    size_t position;

    //========================================
    //Return a duplicate of the given context.
    //========================================
    @property Context dup()
    {
        auto context = new Context;
        context.sentence = sentence;
        context.position = position;

        return context;
    }

    //====================================================
    //Returns the name of the word this context points to.
    //====================================================
    @property string name()
    {
        return sentence[position];
    }
}

//=====================================
//Represents a word that the bot knows.
//=====================================
class Word
{
    //A list of locations where this word is used.
    Context[] contexts;

    //===================================================
    //Returns the name of the word this object points to.
    //===================================================
    @property string name()
    {
        assert(contexts.length);
        return contexts[0].name;
    }
}

//==============================================
//Represents a word that the bot knows, with the
//punctuation stripped off.
//==============================================
class CleanWord
{
    //Words describing different forms of the base word.
    //For example, a CleanWord called 'foo' may point to
    //'foo', 'foo,' and 'foo!'
    Word[] forms;

    //============================================
    //Returns the total number of contexts pointed
    //to by this CleanWord's forms.
    //============================================
    int numcontexts()
    {
        int total = 0;

        foreach(form; forms)
            total += form.contexts.length;

        return total;
    }
}

//==============================================
//Returns the argument with leading and trailing
//punctuation stripped off.
//==============================================
string strip_punct(string word)
{
    //Find the first and last characters that aren't punctuation.
    int first_letter = word.length;
    int last_letter = word.length;

    foreach(i; 0 .. word.length)
    {
        if(!isPunctuation(word[i]))
        {
            last_letter = i;

            if(first_letter == word.length)
                first_letter = i;
        }
    }

    //No actual letters have been found?
    if(last_letter == word.length)
        return "";

    return word[first_letter .. last_letter + 1].toLower();
}

//==========================================
//Takes a line and converts it into an array
//of lowercase words.
//==========================================
string[] split_sentence(string input)
{
    string line;

    //Copy the input into 'line', lowercasing
    //everything and all newlines to whitespace.
    foreach(c; input)
    {
        if(c == '\n' || c == '\r')
            line ~= ' ';

        else
            line ~= c.toLower();
    }

    //Return the sentence split into tokens based on
    //whitespace, excluding any empty words.
    return line.splitter(' ').filter!(a => a.length).array;
}
