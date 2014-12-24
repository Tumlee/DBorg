//This file contains various utilty classes
//that are used by the DBorg class.
module dborg.utilities;

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

    //==============================
    //Constructor for Context class.
    //==============================
    this(string[] sen, size_t pos)
    {
        sentence = sen;
        position = pos;
    }

    //========================================
    //Return a duplicate of the given context.
    //========================================
    @property Context dup()
    {
        return new Context(sentence, position);
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
//Returns the argument with leading and trailing
//punctuation stripped off.
//==============================================
string stripPunct(string word)
{
    //Find the first and last characters that aren't punctuation.
    auto firstLetter = word.length;
    auto lastLetter = word.length;

    foreach(i; 0 .. word.length)
    {
        if(!isPunctuation(word[i]))
        {
            lastLetter = i;

            if(firstLetter == word.length)
                firstLetter = i;
        }
    }

    //No actual letters have been found?
    if(lastLetter == word.length)
        return "";

    return word[firstLetter .. lastLetter + 1].toLower;
}

//==========================================
//Takes a line and converts it into an array
//of lowercase words.
//==========================================
string[] splitSentence(string input)
{
    return input.toLower.split;
}
