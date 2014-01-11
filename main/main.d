import std.stdio;
import std.algorithm;
import std.range;
import DBorg;

string getParm(string args[], string name)
{
    foreach(a; 1 .. args.length - 1)
    {
        if(args[a] == name)
            return args[a + 1];
    }

    return null;
}

bool getSwitch(string args[], string name)
{
    return args[1 .. $].canFind(name);
}

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

    string line;

    while((line = botFile.readln()) !is null)
        bot.learn(line);

    botFile.close();
    return true;
}

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

    foreach(sentence; bot.sentences)
         outFile.writeln(sentence.joiner(" ").array);

    outFile.close();
    return true;
}

void main(string args[])
{
    auto bot = new DBorg;

    string paramTopic = getParm(args, "--topic");
    string paramReply = getParm(args, "--reply");
    string fileName = getParm(args, "--file");
    bool statMode = getSwitch(args, "--stats");
    bool learning = !getSwitch(args, "--no-learning");
    bool saveEnabled = getSwitch(args, "--save-lines");

    if(fileName is null)
        fileName = "lines.txt";

    bot.loadLines(fileName);

    if(paramTopic !is null)
    {
        writeln(bot.sayTopic(paramTopic));
        return;
    }

    if(paramReply !is null)
    {
        writeln(bot.reply(paramReply));
        return;
    }

    if(statMode)
    {
        writefln("%d words", bot.words.length);
        writefln("%d cleanwords", bot.cleanWords.length);
        writefln("%d sentences", bot.sentences.length);
        return;
    }

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
