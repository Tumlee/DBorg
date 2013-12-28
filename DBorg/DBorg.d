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
    CleanWord[string] cleanwords;

    //Variable describing the likelihood that the bot
    //will switch to a different context.
    int sanity = 66;

    //=============================================
    //Adds the input sentence to the bot's library.
    //=============================================
    void learn(string input)
    {
        auto sen = split_sentence(input);

        //Don't learn empty sentences or one-word sentences.
        if(sen.length < 2)
            return;

        foreach(i; 0 .. sen.length)
        {
            //Build a new context.
            auto context = new Context;
            context.sentence = sen;
            context.position = i;

            auto name = context.name;

            //Build a new word if it doesn't already exist.
            if((name in words) is null)
                words[name] = new Word;

            //Build a new clean word if it doesn't already exist.
            auto clean = name.strip_punct();

            //Be careful not to add any empty words to the dictionary.
            if(clean.length)
            {
                if((clean in cleanwords) is null)
                    cleanwords[clean] = new CleanWord;

                if(!cleanwords[clean].forms.canFind(words[name]))
                    cleanwords[clean].forms ~= words[name];
            }

            words[name].contexts ~= context;
        }
    }

    //===========================================
    //Returns a random context of the given word.
    //===========================================
    Context random_context(string name)
    {
        return words[name].contexts[uniform(0, $)];
    }

    //===================================================
    //If the bot knows the topic word, it will reply with
    //a randomly-generated sentence containing that word.
    //===================================================
    string say_topic(string topic)
    {
        if((topic in words) is null)
            return "";

        string[] outwords = [words[topic].name];

        auto base = random_context(topic);

        //Move forward through the list.
        for(auto context = base.dup; true; )
        {
            //Randomly recalculate context.
            if(uniform(0, 100) > sanity)
                context = random_context(context.name).dup;

            //Go to the next word, and break if we passed the end.
            if(context.position++ == context.sentence.length - 1)
                break;

            outwords ~= context.name;
        }

        //Move backward through the list.
        for(auto context = base.dup; true; )
        {
            //Randomly recalculate context.
            if(uniform(0, 100) > sanity)
                context = random_context(context.name).dup;

            //Subtract one to move backward through the sentence.
            if(context.position-- == 0)
                break;

            //Prepend the word to the sentence.
            outwords = context.name ~ outwords;
        }

        //Join the sentence into strings.
        auto outline = outwords.joiner(" ").array;

        //Make that first character uppercase.
        outline[0] = outline[0].toUpper();

        return outline.to!string();
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
        CleanWord choice;

        foreach(wd; input.split_sentence())
        {
            auto cw = wd.strip_punct();

            if(wd in cleanwords)
            {
                if(choice is null)
                    choice = cleanwords[cw];

                if(cleanwords[cw].numcontexts() < choice.numcontexts())
                    choice = cleanwords[cw];
            }
        }

        if(choice is null)
            return "";

        return say_topic(choice.forms[uniform(0, $)].name);
    }
}
