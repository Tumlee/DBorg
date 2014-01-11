import DBorgUtilities;
import std.random;

//======================================================
//A chatbot that learns sentences and generates random
//varations of those sentences. It associates words with
//one another based on where they appear in relation to
//other words it knows.
//======================================================
class DBorg
{
    //The words and sentences known by the bot.
    string[][] sentences;
    Word[string] words;
    Word[string] cleanWords;

    //Variable describing the likelihood that the bot
    //will switch to a different context.
    int sanity = 66;

    //=============================================
    //Adds the input sentence to the bot's library.
    //=============================================
    void learn(string input)
    {
        auto sen = splitSentence(input);

        //Don't learn empty sentences or one-word sentences.
        if(sen.length < 2)
            return;

        //Don't learn duplicate sentences.
        if(sentences.canFind(sen))
            return;

        sentences ~= sen;

        foreach(i; 0 .. sen.length)
        {
            //Build a new context.
            auto context = new Context(sen, i);

            auto name = context.name;

            //Build a new word if it doesn't already exist.
            if((name in words) is null)
                words[name] = new Word;

            //Build a new clean word if it doesn't already exist.
            auto clean = name.stripPunct();

            //Be careful not to add any empty words to the dictionary.
            if(clean.length)
            {
                if((clean in cleanWords) is null)
                    cleanWords[clean] = new Word;

                cleanWords[clean].contexts ~= context;
            }

            words[name].contexts ~= context;
        }
    }

    //===========================================
    //Returns a random context of the given word.
    //===========================================
    Context randomContext(string name)
    {
        return words[name].contexts[uniform(0, $)];
    }

    //===================================================
    //If the bot knows the topic word, it will reply with
    //a randomly-generated sentence containing that word.
    //===================================================
    string sayTopic(string topic)
    {
        if((topic in words) is null)
            return "";

        string[] outWords = [words[topic].name];

        auto base = randomContext(topic);

        //Move forward through the list.
        for(auto context = base.dup; true; )
        {
            //Randomly recalculate context.
            if(uniform(0, 100) > sanity)
                context = randomContext(context.name).dup;

            //Go to the next word, and break if we passed the end.
            if(context.position++ == context.sentence.length - 1)
                break;

            outWords ~= context.name;
        }

        //Move backward through the list.
        for(auto context = base.dup; true; )
        {
            //Randomly recalculate context.
            if(uniform(0, 100) > sanity)
                context = randomContext(context.name).dup;

            //Subtract one to move backward through the sentence.
            if(context.position-- == 0)
                break;

            //Prepend the word to the sentence.
            outWords = context.name ~ outWords;
        }

        //Join the sentence into strings.
        auto outLine = outWords.joiner(" ").array;

        //Make that first character uppercase.
        outLine[0] = outLine[0].toUpper();

        return outLine.to!string();
    }

    //===========================================================
    //Responds with a randomly generated sentence relating to the
    //input string, if it knows any of the words the input string
    //contains. Otherwise, it returns an empty string.
    //===========================================================
    string reply(string input)
    {
        //Pick a topic out of the input to reply to, the best one being
        //the one that exists, but generates the least number of contexts.
        Word choice;

        foreach(wd; input.splitSentence())
        {
            auto cw = wd.stripPunct();

            if(cw in cleanWords)
            {
                if(choice is null)
                    choice = cleanWords[cw];

                if(cleanWords[cw].contexts.length < choice.contexts.length)
                    choice = cleanWords[cw];
            }
        }

        if(choice is null)
            return "";

        return sayTopic(choice.contexts[uniform(0, $)].name);
    }
}
