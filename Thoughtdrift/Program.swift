import Foundation

struct JournalDay: Identifiable {
    let id: Int
    let title: String
    let prompt: String
    let quote: String
    let author: String
}

struct Week: Identifiable {
    let id: Int
    let title: String
    let goal: String
    let summary: String
    let reflection: String
}

struct Distortion: Identifiable {
    let name: String
    let example: String
    let reframe: String
    var id: String { name }
}

enum Program {
    static let days: [JournalDay] = [
        .init(id: 1, title: "Thought Record", prompt: "Describe a situation today that triggered anxiety. What automatic thought ran through your mind?", quote: "The greatest weapon against stress is our ability to choose one thought over another.", author: "William James"),
        .init(id: 2, title: "Name the Distortion", prompt: "Review yesterday's thought. Which cognitive distortion does it match? (Catastrophizing, mind-reading, all-or-nothing, etc.)", quote: "Don't believe everything you think.", author: "Unknown"),
        .init(id: 3, title: "Gather Evidence", prompt: "List three facts that contradict your anxious thought. What would a neutral observer say?", quote: "Facts are stubborn things; and whatever may be our wishes, our inclinations, or the dictates of our passion, they cannot alter the state of facts and evidence.", author: "John Adams"),
        .init(id: 4, title: "The Balanced Reframe", prompt: "Rewrite that thought in a more realistic, compassionate way.", quote: "You are not your thoughts. You are the observer of your thoughts.", author: "Amit Ray"),
        .init(id: 5, title: "Worry Time", prompt: "Set a 15-minute window and dump every worry onto the page. Outside that time, postpone them.", quote: "Anxiety does not empty tomorrow of its sorrows, but only empties today of its strength.", author: "Charles Spurgeon"),
        .init(id: 6, title: "Decatastrophize", prompt: "What's the worst-case scenario? The best-case? The most likely outcome?", quote: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott"),
        .init(id: 7, title: "Body Check-In", prompt: "Where do you hold stress physically? Describe the sensation without labeling it \"bad.\"", quote: "Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.", author: "Thich Nhat Hanh"),
        .init(id: 8, title: "Behavioral Activation", prompt: "Name one thing anxiety made you avoid. What's the tiniest step toward it?", quote: "Action is not just the effect of motivation; it is also the cause of it.", author: "Mark Manson"),
        .init(id: 9, title: "Test Your Prediction", prompt: "Pick a low-stakes activity. Rate predicted anxiety (0–10), do it, then rate actual anxiety.", quote: "You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.", author: "Eleanor Roosevelt"),
        .init(id: 10, title: "Should Statements", prompt: "Catch a \"should\" or \"must\" thought. Rewrite it with preference or flexibility.", quote: "Peace is the result of retraining your mind to process life as it is, rather than as you think it should be.", author: "Wayne Dyer"),
        .init(id: 11, title: "Find the Middle Ground", prompt: "Describe a situation where you saw only extremes. What's the gray area?", quote: "Life is not always black and white. It's a million shades of gray.", author: "Unknown"),
        .init(id: 12, title: "Mind-Reading Audit", prompt: "You assumed someone judged you. What actual evidence do you have?", quote: "We suffer more often in imagination than in reality.", author: "Seneca"),
        .init(id: 13, title: "Emotional Reasoning", prompt: "\"I feel incompetent, so I am.\" Counter this with three concrete skills or past successes.", quote: "You have been assigned this mountain to show others it can be moved.", author: "Unknown"),
        .init(id: 14, title: "Fortune Telling", prompt: "You're predicting failure. What would you tell a friend making the same prediction?", quote: "Courage doesn't always roar. Sometimes courage is the little voice at the end of the day that says I'll try again tomorrow.", author: "Mary Anne Radmacher"),
        .init(id: 15, title: "Magnification Check", prompt: "You blew up a mistake or dismissed a win. Write both at actual size.", quote: "There is nothing either good or bad, but thinking makes it so.", author: "Shakespeare"),
        .init(id: 16, title: "Drop the Label", prompt: "You called yourself a \"failure\" or \"loser.\" Replace the label with specific behaviors.", quote: "You are not a drop in the ocean. You are the entire ocean in a drop.", author: "Rumi"),
        .init(id: 17, title: "Responsibility Pie", prompt: "Something went wrong. Draw/write how much was actually yours vs. external factors.", quote: "Grant me the serenity to accept the things I cannot change, the courage to change the things I can, and the wisdom to know the difference.", author: "Reinhold Niebuhr"),
        .init(id: 18, title: "Control Circle", prompt: "List what's in your control right now and what's not. Practice letting go of the outer ring.", quote: "Incredible change happens in your life when you decide to take control of what you do have power over instead of craving control over what you don't.", author: "Steve Maraboli"),
        .init(id: 19, title: "Situational vs. Global", prompt: "A stressful event happened. How is it specific to this moment, not proof of your whole life?", quote: "This too shall pass. It might pass like a kidney stone, but it will pass.", author: "Unknown"),
        .init(id: 20, title: "Build Your Ladder", prompt: "List feared situations from least to most scary. Commit to the bottom rung tomorrow.", quote: "Do one thing every day that scares you.", author: "Eleanor Roosevelt"),
        .init(id: 21, title: "Approach vs. Avoidance", prompt: "What did you avoid today? Write the short-term relief and the long-term cost.", quote: "The cave you fear to enter holds the treasure you seek.", author: "Joseph Campbell"),
        .init(id: 22, title: "Drop the Safety Behavior", prompt: "What crutch keeps anxiety alive? Experiment without it for 10 minutes and record the result.", quote: "Security is mostly a superstition. Life is either a daring adventure or nothing.", author: "Helen Keller"),
        .init(id: 23, title: "Breathing Anchor", prompt: "Take 5 slow breaths. Between each, write one anxious thought and imagine it floating away.", quote: "Breath is the bridge which connects life to consciousness, which unites your body to your thoughts.", author: "Thich Nhat Hanh"),
        .init(id: 24, title: "Values Alignment", prompt: "What matters to you long-term? Did one small action today reflect that despite the anxiety?", quote: "He who has a why to live can bear almost any how.", author: "Friedrich Nietzsche"),
        .init(id: 25, title: "Problem-Solve", prompt: "Turn one practical worry into a solvable problem. Brainstorm three options and pick a first step.", quote: "You don't have to see the whole staircase, just take the first step.", author: "Martin Luther King Jr."),
        .init(id: 26, title: "Self-Compassion Letter", prompt: "Write to yourself exactly as you would comfort a dear friend facing the same stress.", quote: "Be gentle with yourself. You're doing the best you can.", author: "Unknown"),
        .init(id: 27, title: "Gratitude Bias", prompt: "Anxiety scans for threats. Deliberately list three things that went okay or better than expected.", quote: "It is not happiness that makes us grateful, but gratefulness that makes us happy.", author: "David Steindl-Rast"),
        .init(id: 28, title: "Park for Tomorrow", prompt: "Write your top three priorities for tomorrow, then practice \"parking\" them until morning.", quote: "Tomorrow is tomorrow. Future cares have future cures, and we must mind today.", author: "Sophocles"),
        .init(id: 29, title: "Prediction vs. Reality", prompt: "You feared a social outcome. What actually happened? Compare the two.", quote: "The only way out is through.", author: "Robert Frost"),
        .init(id: 30, title: "Relapse Prevention", prompt: "Review the month. Which CBT tool helped most? Plan exactly how you'll use it when stress returns.", quote: "Fall seven times, stand up eight.", author: "Japanese Proverb")
    ]

    static let weeks: [Week] = [
        .init(id: 1, title: "Thought Awareness", goal: "Learn to catch and name anxious thoughts.", summary: "You've just spent seven days learning to notice your thoughts. That's harder than it sounds. This week was about building awareness, not fixing anything. If you caught even one anxious thought and named it, you're on track.", reflection: "Which distortion showed up most often? Write it down so you can spot it faster next week."),
        .init(id: 2, title: "Challenge & Action", goal: "Stop letting anxiety make the rules.", summary: "You started testing your anxious predictions and rewriting rigid \"should\" thoughts. That takes real courage. Some days felt lighter; others felt like a slog. Both are normal.", reflection: "Which day felt most useful? What made that prompt stick?"),
        .init(id: 3, title: "Exposure & Responsibility", goal: "Change the narrative and face fears gradually.", summary: "You practiced shrinking catastrophes, dropping harsh labels, and taking small steps toward feared situations. Exposure isn't about being fearless; it's about not letting fear decide for you.", reflection: "What's one thing you approached this week that you would have avoided two weeks ago?"),
        .init(id: 4, title: "Values & Maintenance", goal: "Anchor skills in self-compassion and long-term practice.", summary: "You anchored your practice in values, self-compassion, and problem-solving. You also made a plan for tough days ahead. That plan is your safety net, not a sign you're backsliding.", reflection: "Which CBT tool will you keep in your pocket? Commit to using it within the next seven days.")
    ]

    static let distortions: [Distortion] = [
        .init(name: "All-or-Nothing Thinking", example: "Seeing things in black-and-white categories. “If I'm not perfect, I'm a failure.”", reframe: "Most outcomes are mixed. What did I do partially well?"),
        .init(name: "Catastrophizing", example: "Assuming the worst will happen. “This headache means something terrible.”", reframe: "What's the most likely outcome? What's happened before?"),
        .init(name: "Mind-Reading", example: "Believing you know what others think without evidence. “They must think I'm awkward.”", reframe: "What did they actually say or do? Am I guessing?"),
        .init(name: "Emotional Reasoning", example: "“I feel it, so it must be true.” “I feel useless, so I am useless.”", reframe: "Feelings are data, not facts. What evidence contradicts this?"),
        .init(name: "Should Statements", example: "Using “should,” “must,” or “ought” to motivate or judge. “I should be over this by now.”", reframe: "What would I say to a friend in this situation?"),
        .init(name: "Magnification / Minimization", example: "Blowing negatives out of proportion or shrinking positives. “The compliment doesn't count; the criticism does.”", reframe: "Write the event at actual size. What's one real strength I showed?"),
        .init(name: "Labeling", example: "Attaching a global negative label to yourself. “I'm a loser.” “I'm broken.”", reframe: "Replace the label with specific behaviors. What exactly happened?"),
        .init(name: "Fortune Telling", example: "Predicting negative outcomes as if they're guaranteed. “I'll definitely mess up the presentation.”", reframe: "Have I been right every time I predicted the future? What's another possibility?"),
        .init(name: "Mental Filter", example: "Dwelling on a single negative detail and ignoring everything else.", reframe: "What else happened today that was neutral or positive?"),
        .init(name: "Personalization", example: "Blaming yourself for things outside your control. “The team failed because of me.”", reframe: "What other factors played a role? What was genuinely my responsibility?")
    ]
}
