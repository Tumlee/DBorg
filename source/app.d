import std.stdio;
import std.algorithm;
import std.range;
import dborg.bot;

//==============================================================
//Returns the value of the given command line parameter (defined
//as the parm directly following the one that matches 'name').
//==============================================================
string getParm(string[] args, string name)
{
    foreach(a; 1 .. args.length - 1)
    {
        if(args[a] == name)
            return args[a + 1];
    }

    return null;
}

//=============================================================
//Returns true if the given parameter is in the parameter list.
//=============================================================
bool getSwitch(string[] args, string name)
{
    return args[1 .. $].canFind(name);
}

//=====================================================================
//Loads a library of lines into the given bot, with the given filename.
//Returns true on success, false upon failure.
//=====================================================================
bool loadLines(DBorg bot, string fileName)
{
    //Open the file.
    File botFile;

    try
    {
        botFile = File(fileName, "r");
    }
    catch(std.exception.ErrnoException)
    {
        return false;
    }
    
    //Learn each line in the file.
    foreach(line; botFile.byLineCopy)
        bot.learn(line);

    botFile.close();
    return true;
}

//===================================================================
//Saves the bot's known lines as a text file with the given filename.
//Returns true on success, false upon failure.
//===================================================================
bool saveLines(DBorg bot, string fileName)
{
    File outFile;

    try
    {
        outFile = File(fileName, "w");
    }
    catch(std.exception.ErrnoException)
    {
        return false;
    }

    //Save each sentence as its own line in the file.
    foreach(sentence; bot.sentences)
         outFile.writeln(sentence.joiner(" ").array);

    outFile.close();
    return true;
}

void main(string[] args)
{
    auto bot = new DBorg;

    //Read through the command line parameters.
    string paramTopic = getParm(args, "--topic");
    string paramReply = getParm(args, "--reply");
    string fileName = getParm(args, "--file");
    bool statMode = getSwitch(args, "--stats");
    bool learning = !getSwitch(args, "--no-learning");
    bool saveEnabled = getSwitch(args, "--save-lines");

    //Default to 'lines.txt' for a library file if none is specified.
    if(fileName is null)
        fileName = "lines.txt";

    bot.loadLines(fileName);
    
    //The 'topic' parameter forces the bot to talk about the given topic
    //and immediately terminate.
    if(paramTopic !is null)
    {
        writeln(bot.sayTopic(paramTopic));
        return;
    }

    //The 'reply' parameter forces the bot to reply to the given sentence,
    //and then immediately terminate.
    if(paramReply !is null)
    {
        writeln(bot.reply(paramReply));
        return;
    }

    //The 'stats' parameter displays statistics about the bot's dictionary.
    if(statMode)
    {
        writefln("%d words", bot.words.length);
        writefln("%d cleanwords", bot.cleanWords.length);
        writefln("%d sentences", bot.sentences.length);
        return;
    }

    //Main loop for interactively chatting with the bot.
    while(true)
    {
        write("<You> ");

        string input = readln();

        if(input == null)
            break;

        writefln("<Bot> %s", bot.reply(input));

        if(learning)
            bot.learn(input);
    }

    if(saveEnabled)
        bot.saveLines(fileName);
}
