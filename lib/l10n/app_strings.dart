import '../features/lesson/domain/self_check_reason.dart';

/// Centralized application strings and accessibility labels.
///
/// Follows AGENTS.md requirement that all UI text is localized and not hardcoded.
abstract final class AppStrings {
  // Navigation & Actions
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get started';
  static const String skipSemantics = 'Skip introduction';
  static const String nextSemantics = 'Next page';

  // Onboarding Welcome Page 1
  static const String welcome1Title = "Learn what you'll actually say";
  static const String welcome1Subtitle =
      'Short lessons built from real conversations — not word lists you forget.';
  static const String welcome1Chip1 = '9 quick activities';
  static const String welcome1Chip2 = 'About 3 minutes';
  static const String welcome1Chip3 = 'Audio from the first tap';

  // Onboarding Welcome Page 2
  static const String welcome2Title = 'Practise real moments';
  static const String welcome2Subtitle =
      'Order a coffee, ask for directions, walk into an interview. Pebbi plays the other person.';
  static const String welcome2Chip1 = 'Café';
  static const String welcome2Chip2 = 'Airport';
  static const String welcome2Chip3 = 'Job interview';

  // Onboarding Welcome Page 3
  static const String welcome3Title = 'No pressure, just progress';
  static const String welcome3Subtitle =
      'No hearts, no countdowns, no guilt. Miss a day and Pebbi is right here.';
  static const String welcome3Chip1 = 'Streak freezes';
  static const String welcome3Chip2 = 'Go at your pace';
  static const String welcome3Chip3 = 'Never shamed';
  static const String welcome3Caption = 'Free to start. No card, no countdown.';

  // Accessibility helpers
  static String pageIndicatorSemantics(int current, int total) =>
      'Page $current of $total';
  static String stepProgressSemantics(int current, int total) =>
      'Step $current of $total';
  static String yearFieldSemantics(int year) =>
      'Year of birth, $year. Double tap to select year';

  // Onboarding Setup Flow
  static const String back = 'Back';
  static const String backSemantics = 'Go back';
  static const String continueAction = 'Continue';

  // Setup Step 2: Age
  static const String howOldAreYouTitle = 'How old are you?';
  static const String howOldAreYouSubtitle = 'We ask so we can keep you safe.';
  static const String yearOfBirthLabel = 'YEAR OF BIRTH';
  static const String privacyNoteAdult =
      'All set. We store only the age band, never your birthday.';
  static const String privacyNoteChild =
      'Pebbi is for ages 13 and up. Ask a grown-up to set this up with you — we store only your age band, nothing else.';
  static const String yearPickerTitle = 'Select Year of Birth';
  static const String confirm = 'Confirm';

  // Setup Step 3: Explanation Language ("I speak...")
  static const String iSpeakTitle = 'I speak...';
  static const String iSpeakSubtitle =
      'This is the language of explanations and hints.';
  static const String searchLanguagesPlaceholder = 'Search languages';
  static const String noLanguagesFound = 'No languages found';
  static const String translationsPendingNotice =
      'Lesson translations are English at launch while native reviewers check the rest — your choice is saved and used for Pebbi\'s explanations and mission feedback.';
  static String languageChipSemantics(String language, bool isSelected) =>
      isSelected ? '$language, selected' : language;

  // Setup Step 4: Target Language ("I want to learn...")
  static const String iWantToLearnTitle = 'I want to learn...';
  static const String iWantToLearnSubtitle = 'Tap a card to hear hello.';
  static const String moreComingSoon = 'More coming soon';
  static const String comingSoonFeedback = 'Coming soon';
  static const String voiceNotAvailable =
      'Voice not available on this device for this language.';

  static String learnersCountFormatted(String compactNumber) =>
      '$compactNumber learners';

  static String difficultyPipsSemantics(int filled, int total) =>
      'Difficulty $filled of $total';

  static String availableCardSemantics({
    required String nativeName,
    required String englishName,
    required int difficulty,
    required int totalDifficulty,
    required String learnersText,
    required bool isSelected,
  }) {
    final base =
        '$nativeName, $englishName, difficulty $difficulty of $totalDifficulty, $learnersText';
    return isSelected ? '$base, selected' : base;
  }

  static String comingSoonCardSemantics(String englishName) =>
      '$englishName, coming soon, not available';

  // Setup Step 5: Learning Reasons ("Why are you learning?")
  static const String whyAreYouLearningTitle = 'Why are you learning?';
  static const String whyAreYouLearningSubtitle =
      'Pick up to three. This sets your first track and missions.';
  static const String backpackEmpty = "Pebbi's backpack is empty";
  static const String maxReasonsReached = 'You can pick up to three';
  static const String reasonsSelectionGroupSemantics =
      'Pick up to three reasons for learning';

  static String backpackPacked(int count, {int max = 3}) =>
      '$count of $max stickers packed';

  static String reasonCardSemantics(String label, bool isSelected) =>
      isSelected ? '$label, selected' : '$label, not selected';

  // Setup Step 6: Placement Intro ("Let's see what you already know")
  static const String placementIntroTitle = "Let's see what you already know";

  /// Formatted dynamic subtitle for placement intro with parameters and plural handling.
  static String placementIntroSubtitle({
    required String language,
    required int questionsCount,
    required int minutes,
  }) {
    final countWord = switch (questionsCount) {
      1 => 'One',
      2 => 'Two',
      3 => 'Three',
      4 => 'Four',
      5 => 'Five',
      6 => 'Six',
      7 => 'Seven',
      8 => 'Eight',
      9 => 'Nine',
      10 => 'Ten',
      _ => '$questionsCount',
    };
    final questionsPlural = questionsCount == 1 ? 'quick one' : 'quick ones';
    final minutesWord = switch (minutes) {
      1 => 'one minute',
      2 => 'two minutes',
      3 => 'three minutes',
      4 => 'four minutes',
      5 => 'five minutes',
      _ => '$minutes minutes',
    };
    return '$countWord $questionsPlural in $language. About $minutesWord.';
  }

  // Card 1
  static const String placementCard1Title = 'It gets easier as you go';
  static const String placementCard1Body =
      'The first questions are gentle, then they get harder until they find your edge. Getting one wrong is part of the design — that\'s how we know where to start you.';

  // Card 2
  static const String placementCard2Title = 'No scores, no shaming';
  static const String placementCard2Body =
      'You never see a fail. Whatever you answer, Pebbi tunes your lessons to you and your streak starts today.';

  // Chips
  static const String placementChipNoTimer = 'No timer';
  static const String placementChipSkipAnything = 'Skip anything';
  static const String placementChipEndsInAWin = 'Ends in a win';

  // Pinned Bottom Actions
  static const String placementStartButton = 'Start the quick check';
  static const String placementStartButtonSemantics =
      'Start the quick check quiz';

  static String placementSkipAction(String levelName) =>
      'I\'m brand new — start me at $levelName';

  static String placementSkipActionSemantics(String levelName) =>
      'I\'m brand new, start me at $levelName. Skips the quick check.';

  // Exercise Engine & Placement Quick Check
  static const String pickThePictureTitle = 'Pick the picture';
  static const String hearIt = 'Hear it';
  static const String hearItSemantics = 'Hear phrase pronunciation';
  static const String check = 'Check';
  static const String checkDisabledSemantics = 'Check answer, disabled';
  static const String hint = 'Hint';
  static const String hintSemantics = 'Hint, removes one wrong option';
  static const String hintDisabledSemantics = 'Hint disabled';

  // Feedback Panel
  static const String feedbackCorrectTitle = '✓ Nice one!';
  static const String feedbackWrongTitle = '✕ Not quite — you\'re learning!';
  static String feedbackCorrectAnswer(String answer) =>
      'Correct answer: $answer';
  static const String feedbackRedoNotice = 'We\'ll try it again at the end.';
  static const String why = 'Why?';
  static const String whySemantics = 'Why? View answer explanation';
  static const String whySheetTitle = 'Why this answer';
  static const String continueExercise = 'Continue';
  static const String continueExerciseSemantics = 'Continue to next question';

  // Header & Confirmation
  static const String closeExerciseSemantics = 'Close check';
  static String questionProgressSemantics(int current, int total) =>
      'Question $current of $total';
  static String pictureOptionSemantics({
    required int index,
    required int total,
    required String label,
    required bool isSelected,
  }) {
    final base = 'Option $index of $total, $label';
    return isSelected ? '$base, selected' : base;
  }

  // "What does this mean?" Exercise
  static const String whatDoesThisMean = 'What does this mean?';
  static const String playAudio = 'Play audio';
  static const String playingAudio = 'Playing audio';
  static String textOptionSemantics({
    required int index,
    required int total,
    required String text,
    required bool isSelected,
  }) {
    final base = 'Option $index of $total, $text';
    return isSelected ? '$base, selected' : base;
  }

  // Exit Confirmation Dialog
  static const String exitConfirmTitle = 'Leave this check?';
  static const String exitConfirmBody = 'Your answers so far will be lost.';
  static const String exitConfirmStay = 'Stay';
  static const String exitConfirmLeave = 'Leave';

  // "Build the sentence" Exercise
  static const String tapWordsInOrderHint = 'Tap the words below in order...';
  static const String tilesFlyUpTip = 'Tiles fly up when you tap them';
  static String tileInBankSemantics(String text) =>
      'Word tile $text. Double tap to place into sentence.';
  static String tileInAnswerSemantics(String text, int position, int total) =>
      'Placed word tile $text, position $position of $total. Double tap to return to bank.';

  // Lesson Player & Item Types
  static const String newPhraseTag = 'New phrase';
  static const String casualRegisterTag = 'casual';
  static const String politeRegisterTag = 'polite';
  static const String speedNormal = 'Normal';
  static const String speedNormalSemantics = 'Play at normal speed';
  static const String speedSlow = 'Slow';
  static const String speedSlowSemantics = 'Play slowly';
  static const String phrasebookHint =
      'Tap any word you want to keep in your phrasebook.';
  static const String gotIt = 'Got it';
  static const String gotItSemantics = 'Got it, continue to next item';
  static String tokenTapToSave(String text) =>
      '$text, tap to keep in your phrasebook';
  static String tokenTappedSaved(String text) =>
      '$text, kept in your phrasebook';

  // Match the pairs
  static const String matchPairsTitle = 'Match the pairs';
  static String matchPairsProgress(int matched, int total) =>
      '$matched of $total matched';
  static const String matchPairsNote = 'Match every pair to carry on';
  static const String matchPairsNotAPair = 'Not a pair, try again';
  static String matchPairsCardSelected(String text) => '$text, selected';
  static String matchPairsCardMatched(String text1, String text2) =>
      '$text1 matched with $text2';

  // Tap what you hear & Choose the reply
  static const String tapWhatYouHearTitle = 'Tap what you hear';
  static const String cantListenNow = "Can't listen now";
  static const String cantListenNowSemantics =
      "Can't listen now, skip without penalty";
  static const String chooseTheReplyTitle = 'Choose the reply';
  static const String tapToHearAgain = 'Tap to hear again';
  static const String tapToHearAgainSemantics = 'Tap to hear dialogue again';
  static String streakInARow(int count) => '$count in a row!';

  // Speaking Exercise (Screen A & Screen B)
  static const String speakingPlaceholderTitle = 'Say it out loud';
  static const String speakingPlaceholderBody =
      'Speaking exercise\n(coming next)';
  static const String speakTitle = 'Say it out loud';
  static const String speakTapMicPrompt = 'Tap the mic and say the sentence';
  static const String speakRatherNotAction =
      "I'd rather not speak right now";
  static const String speakRatherNotActionSemantics =
      "I'd rather not speak right now, switch to self-check";
  static const String speakTipNote = 'Speak, or skip — nothing is lost';
  static const String micReadySemantics =
      'Microphone ready. Tap to start speaking.';
  static const String micListeningSemantics =
      'Listening... Speak the phrase now. Tap to stop.';
  static const String micDisabledSemantics = 'Microphone disabled.';
  static const String micStopActionSemantics = 'Stop listening';
  static const String speakMatchedFeedback = '✓ Perfect pronunciation!';

  // Self-Check Fallback (Screen B)
  static const String selfCheckTitle = 'Say it aloud, then tap below';
  static const String selfCheckSubNotHeard =
      "Didn't catch that — try saying it to yourself!";
  static const String selfCheckSubUserChose =
      'No problem at all — practice saying it quietly.';
  static const String selfCheckSubPermissionDenied =
      'Microphone access is off — you can still practice aloud.';
  static const String selfCheckSubUnavailable =
      "Speech recognition isn't available right now — say it aloud!";
  static const String selfCheckSubSettingOff =
      'Speaking practice is turned off in Settings.';
  static const String selfCheckSubPolicy =
      'Voice practice is paused under current safety policy.';
  static const String selfCheckHearAgain = '🔊 Hear it again';
  static const String selfCheckHearAgainSemantics =
      'Play phrase pronunciation again';
  static const String selfCheckSaidItAction = 'I said it ✓';
  static const String selfCheckHalfCreditLabel = '(half credit)';
  static const String selfCheckSaidItSemantics =
      'I said it, earn half credit';
  static const String selfCheckSkipAction = 'Skip for now';
  static const String selfCheckSkipSemantics =
      'Skip this speaking exercise without penalty';

  static String selfCheckSubtitleFor(SelfCheckReason? reason) {
    switch (reason) {
      case SelfCheckReason.userChose:
        return selfCheckSubUserChose;
      case SelfCheckReason.permissionDenied:
        return selfCheckSubPermissionDenied;
      case SelfCheckReason.unavailable:
        return selfCheckSubUnavailable;
      case SelfCheckReason.settingOff:
        return selfCheckSubSettingOff;
      case SelfCheckReason.policy:
        return selfCheckSubPolicy;
      case SelfCheckReason.notHeard:
      case null:
        return selfCheckSubNotHeard;
    }
  }

  static const String lessonFinishPlaceholderTitle = 'Lesson Complete';

  // Lesson Complete Screen
  static const String lessonCompleteTitle = 'Lesson complete!';
  static const String continueButton = 'Continue';
  static const String lessonCompleteDefaultSubtitle = "You're doing great.";

  static String lessonCompleteSubtitleForStars(int stars) {
    switch (stars) {
      case 3:
        return "You're doing great.";
      case 2:
        return 'Nice progress! Keep it up.';
      case 1:
        return 'Good practice! Every step counts.';
      case 0:
      default:
        return 'You made it through! Practice builds fluency.';
    }
  }

  static String firstTryCountLine(int correct, int total) =>
      '$correct of $total right on the first try';

  static const String youCanNowSayTitle = 'You can now say';

  static String moreLearnedPhrasesCount(int count) => '+$count more';

  static String dayStreakValueLabel(int days) => 'day streak';

  static const String goalDoneTitle = 'Goal done!';
  static const String dailyGoalLabel = 'daily goal';

  static String phraseRowSemantics({
    required String phrase,
    required String meaning,
  }) =>
      '$phrase. $meaning. Double tap to hear it.';

  static String lessonCompleteAnnouncement({
    required int stars,
    required int correct,
    required int total,
  }) =>
      'Lesson complete. $stars of 3 stars. $correct of $total right on the first try.';

  // Placement Results Screen
  static const String placementResultSubtitle =
      "That's your spot — and nothing here locks you in.";
  static String placementFirstTryScore(int firstTry, int total) =>
      '$firstTry/$total first try';
  static String placementDayStreakSaved(int day) => 'Day $day streak saved';
  static const String whatHappensNowTitle = 'What happens now';
  static const String alreadySaidRightTitle = 'You already said these right';
  static const String startFromHere = 'Start from here';
  static const String chooseADifferentLevel = 'Choose a different level';
  static String levelChangedAnnouncement(String levelName) =>
      'Level changed to $levelName';
  static String levelOptionSemantics({
    required String name,
    required String description,
    required int index,
    required int total,
    required bool isSelected,
  }) {
    final base = '$name, $description, option $index of $total';
    return isSelected ? '$base, selected' : '$base, not selected';
  }

  // Setup Step 7: Daily Goal
  static const String dailyGoalTitle = 'Daily goal';
  static const String dailyGoalSubtitle =
      'Missed a day? No problem. Pebbi will be right here.';
  static const String dailyGoalGroupSemantics = 'Daily goal';
  static const String dailyGoalCasual = 'Casual';
  static const String dailyGoalRegular = 'Regular';
  static const String dailyGoalSerious = 'Serious';
  static const String dailyGoalIntense = 'Intense';

  /// Formatted dynamic minutes caption with parameters (e.g. "10 min a day", "20+ min a day").
  static String dailyGoalMinutesCaption(
    int minutes, {
    bool isOpenEnded = false,
  }) => isOpenEnded ? '$minutes+ min a day' : '$minutes min a day';

  /// Spoken minutes description for screen readers (e.g. "10 minutes a day", "20 or more minutes a day").
  static String dailyGoalMinutesSpeech(
    int minutes, {
    bool isOpenEnded = false,
  }) =>
      isOpenEnded ? '$minutes or more minutes a day' : '$minutes minutes a day';

  /// Formatted Settings chip string (e.g. "Regular · 10 min a day").
  static String dailyGoalSettingsChip(
    String name,
    int minutes, {
    bool isOpenEnded = false,
  }) => '$name · ${dailyGoalMinutesCaption(minutes, isOpenEnded: isOpenEnded)}';

  /// Accessible semantics for daily goal cards: "Regular, 10 minutes a day, option 2 of 4, selected".
  static String dailyGoalCardSemantics({
    required String name,
    required int minutes,
    required int index,
    required int total,
    required bool isSelected,
    bool isOpenEnded = false,
  }) {
    final speechMinutes = dailyGoalMinutesSpeech(
      minutes,
      isOpenEnded: isOpenEnded,
    );
    final base = '$name, $speechMinutes, option $index of $total';
    return isSelected ? '$base, selected' : base;
  }

  // Setup Step 8: Daily Reminder ("A gentle nudge?")
  static const String reminderTitle = 'A gentle nudge?';
  static const String reminderSubtitle =
      'Pebbi nudges you once a day, never more.';
  static const String reminderTimeLabel = 'Reminder time';
  static const String saveAndContinue = 'Save and continue';
  static const String reminderNoteActive =
      'You can change or silence this any time in Settings. Pebbi never nudges twice in a day, and quiet hours are respected.';
  static const String reminderNoteDisabled =
      'Reminders are turned off. You can set a time and choose days whenever you want them.';
  static const String remindersDisabledNotice =
      'Reminders are off in your phone settings';
  static const String openSettings = 'Settings';
  static const String reminderNotificationTitle =
      'Time for a quick chat with Pebbi!';
  static const String reminderNotificationBody =
      'Just 3 minutes to keep your streak going.';

  static String reminderTimeSemantics(String timeDisplay) =>
      'Reminder time: $timeDisplay. Double tap to change time';

  static String weekdayChipSemantics({
    required String dayName,
    required bool isSelected,
  }) => isSelected ? '$dayName, selected' : '$dayName, not selected';

  // Setup Step 9: Meet Pebbi (Accent Colour & First Sticker)
  static const String meetPebbiTitle = 'Meet Pebbi';
  static const String meetPebbiSubtitle =
      'Nice to meet you! Pick an accent colour and your first sticker.';
  static const String accentColourLabel = 'ACCENT COLOUR';
  static const String yourFirstStickerLabel = 'YOUR FIRST STICKER';

  static const String accentVioletName = 'Violet';
  static const String accentGreenName = 'Green';
  static const String accentOrangeName = 'Orange';
  static const String accentBlueName = 'Blue';
  static const String accentPinkName = 'Pink';
  static const String accentSlateName = 'Dark slate';

  static const String stickerFirstHello = 'First hello';
  static const String stickerLittleSpark = 'Little spark';
  static const String stickerWellSaid = 'Well said';

  static String accentSwatchSemantics({
    required String name,
    required int index,
    required int total,
    required bool isSelected,
  }) => '$name, option $index of $total${isSelected ? ', selected' : ''}';

  static String accentChangedAnnouncement(String name) => 'Pebbi is now $name';

  static String stickerSemantics({
    required String name,
    required int index,
    required int total,
    required bool isSelected,
  }) => '$name, option $index of $total${isSelected ? ', selected' : ''}';

  static String firstSentenceCaption(String languageName) =>
      'Your first $languageName sentence';

  static String helloPillSemantics({
    required String phrase,
    required String languageName,
  }) => 'Play your first $languageName sentence: $phrase';

  // Setup Step 10: Premium Offer ("You're all set")
  static const String premiumOfferTitle = "You're all set";
  static const String premiumOfferSubtitle =
      'Your level is picked and your first lesson is ready.';
  static const String oneLastThing = 'One last thing';
  static const String premiumCardTitle = 'Keep every door open';
  static const String premiumBenefit1 = 'Every unit and stop, from today';
  static const String premiumBenefit2 = 'All five languages on one streak';
  static const String premiumBenefit3 = 'Unlimited missions and no ads';
  static const String seePremiumOptions = 'See premium options';
  static const String startFreeAction = 'Start free — my first unit is open';

  static const String premiumOptionsPlaceholderTitle = 'Premium Options';
  static const String premiumOptionsPlaceholderSubtitle =
      'Subscription tiers, pricing details, and store terms will appear here.';
  static const String backToOfferAction = 'Back to offer';

  /// Generates the dynamic offer caption with plural-safe trial days and locale-formatted price.
  static String premiumOfferCaption({
    required int trialDays,
    required String formattedPrice,
    required String period,
    bool canWatchAdForFreeDay = false,
  }) {
    final daysText = '$trialDays ${trialDays == 1 ? 'day' : 'days'} free';
    final base = '$daysText, then $formattedPrice a $period.';
    if (canWatchAdForFreeDay) {
      return '$base Or watch a short ad for a free day.';
    }
    return base;
  }

  /// Screen reader announcement grouping the premium card title, benefit list, and caption.
  static String premiumCardSemantics({
    required String title,
    required List<String> benefits,
    String? caption,
  }) {
    final listText = benefits.join(', ');
    if (caption != null && caption.isNotEmpty) {
      return '$title. $listText. $caption';
    }
    return '$title. $listText.';
  }

  // Setup Step 11: Path Ready ("Your path is ready")
  static const String pathReadyTitle = 'Your path is ready';
  static const String pathReadyPreparingAnnouncement =
      'Getting your path ready';
  static const String pathReadyFinishedAnnouncement = 'Your path is ready';

  static const String taskAudioReady = 'Headphones on — audio is ready';
  static const String taskStickerStarted = 'Sticker book started';
  static const String taskSpeakingUnlocked = 'Speaking practice unlocked';

  static const String taskStatusDone = 'Done';
  static const String taskStatusPending = 'Pending';
  static const String taskStatusFailed = 'Failed';
  static const String taskStatusUnavailable = 'Not available';
  static const String retryAction = 'Retry';

  static const String saveProfileErrorNotice =
      'Unable to save your learning profile. Please try again.';

  static const String lessonPlaceholderSubtitle =
      'Your interactive lesson exercises and dialogue will load here.';

  /// Dynamic note displaying estimated duration for the first path lesson.
  static String firstLessonDurationNote(int minutes) =>
      'Your first lesson takes about $minutes minutes.';

  /// Dynamic primary button label with data-driven first lesson number.
  static String startLessonAction(int lessonNumber) =>
      'Start lesson $lessonNumber';

  /// Accessible announcement when a readiness preparation task completes.
  static String taskCompletedAnnouncement(String label) => '$label, done';

  /// Accessible progress percentage value for screen readers.
  static String ringProgressSemantics(int percent) =>
      'Path preparation progress: $percent%';

  /// Screen reader announcement combining emoji description and task status.
  static String readinessRowSemantics({
    required String label,
    required String statusText,
  }) => '$label, $statusText';

  // Premium Screen: "Unlock all of Pebbi"
  static const String unlockAllTitle = 'Unlock all of Pebbi';
  static const String unlockAllSubtitle =
      'Every unit, every language, every mission. One price, and Pebbi keeps the streak with you.';

  // Premium Feature Items (Data-driven keys)
  static const String premiumFeatureUnitsTitle = 'Every unit and stop';
  static const String premiumFeatureUnitsCaption =
      'No locked doors on the path';
  static const String premiumFeatureLanguagesTitle = 'All five languages';
  static const String premiumFeatureLanguagesCaption =
      'Spanish, French, German, Japanese, Arabic';
  static const String premiumFeatureMissionsTitle = 'Unlimited missions';
  static const String premiumFeatureMissionsCaption =
      'Real conversations, as many as you like';
  static const String premiumFeatureNoAdsTitle = 'No ads at all';
  static const String premiumFeatureNoAdsCaption =
      "Not one, once you're premium";
  static const String premiumFeatureOfflineTitle = 'Offline packs';
  static const String premiumFeatureOfflineCaption =
      'A unit in your pocket for the flight';
  static const String premiumFeatureExamsTitle = 'Exam tracks';
  static const String premiumFeatureExamsCaption =
      'DELE, DELF, Goethe, JLPT and more';

  // Plan Card
  static const String mostPopularPill = 'Most popular';
  static const String defaultPlanTitle = 'Pebbi Monthly';

  /// Generates dynamic trial sentence with ICU pluralization.
  ///
  /// TODO(question): Verify "cancel any time, in one tap" against real App Store/Google Play cancellation steps.
  static String trialDaysLine(int days) =>
      'First $days ${days == 1 ? 'day' : 'days'} free · cancel any time, in one tap';

  /// Badge pill displayed at the top right of the premium header (e.g. "7 days free").
  static String trialDaysPill(int days) =>
      '$days ${days == 1 ? 'day' : 'days'} free';

  /// Billing period suffix (e.g. "/month", "/year").
  static String billingPeriodSuffix(String period) => '/$period';

  // Plan Benefits
  static const String planBenefitEveryUnit = 'Every unit in every language';
  static const String planBenefitChestsBadges =
      'Chests, badges and the sticker book open wider';
  static const String planBenefitCancelAnyTime =
      'Cancel any time, keep your stars';

  // Purchase Actions & States
  static const String startMyFreeWeek = 'Start my free week';
  // TODO(question): Confirm non-trial button wording with design/client.
  static const String subscribeAction = 'Subscribe';
  static const String purchaseProcessing = 'Processing, please wait';
  static const String purchaseErrorBanner =
      'Purchase could not be completed. Please try again.';
  static const String plansLoadError =
      'Unable to load subscription plans. Please check your connection.';
  static const String closeSemantics = 'Close';

  // Already Premium State
  // TODO(question): Full design for already-premium state not specified in visual screenshot.
  static const String alreadyPremiumTitle = "You're already premium";
  static const String alreadyPremiumSubtitle =
      'All units, languages, and missions are unlocked.';

  // Legal & Store Compliance Placeholders
  // TODO(question): Apple/Google compliance requires Terms of Service, Privacy Policy, and Restore Purchases.
  static const String legalTerms = 'Terms of Service';
  static const String legalPrivacy = 'Privacy Policy';
  static const String legalRestore = 'Restore Purchases';

  /// Accessibility summary for feature cards list.
  static String featureCardSemantics(String title, String caption) =>
      '$title. $caption.';

  /// Accessibility summary grouping the entire plan card.
  static String planCardSemantics({
    required String planTitle,
    required String price,
    required String period,
    bool isMostPopular = false,
    String? trialLine,
    required List<String> benefits,
  }) {
    final popText = isMostPopular ? '$mostPopularPill. ' : '';
    final trialText = trialLine != null && trialLine.isNotEmpty
        ? '$trialLine. '
        : '';
    final benefitsText = benefits.join('. ');
    return '$planTitle. $popText$price per $period. $trialText$benefitsText.';
  }

  // Auth Screen: Login ("Welcome back")
  static const String welcomeBackTitle = 'Welcome back';
  static const String welcomeBackSubtitle =
      'Log in to pick up your streak where you left it';
  static const String pebbiWordmark = 'Pebbi';
  static const String continueWithGoogle = 'Continue with Google';
  static const String orDivider = 'OR';
  static const String emailLabel = 'Email';
  static const String emailPlaceholder = 'you@example.com';
  static const String passwordLabel = 'Password';
  static const String passwordPlaceholder = '••••••••';
  static const String forgotPassword = 'Forgot password?';
  static const String logInAction = 'Log in';
  static const String loggingInProcessing = 'Logging in, please wait';
  static const String newToPebbi = 'New to Pebbi?';
  static const String createAnAccount = 'Create an account';

  // Auth Accessibility Semantics
  static const String showPasswordSemantics = 'Show password';
  static const String hidePasswordSemantics = 'Hide password';
  static const String closeLoginSemantics = 'Close log in';
  static const String googleSignInSemantics = 'Continue with Google';

  // Auth Error Messages
  static const String authErrorEmailEmpty = 'Please enter your email';
  static const String authErrorEmailInvalid =
      'Please enter a valid email address';
  static const String authErrorPasswordEmpty = 'Please enter your password';
  static const String authErrorInvalidCredentials =
      'Email or password is incorrect';
  static const String authErrorNetwork = 'Check your connection';
  static const String authErrorTooManyAttempts =
      'Too many attempts. Please try again later.';
  static const String authErrorAccountDisabled =
      'This account has been disabled.';
  static const String authErrorUnknown = 'Unable to log in. Please try again.';

  // Auth Screen: Register ("Create your account")
  static const String createAccountTitle = 'Create your account';
  static const String createAccountSubtitle =
      'Your streak, stars and phrasebook on every device';
  static const String confirmPasswordLabel = 'Confirm password';
  static const String createAccountAction = 'Create account';
  static const String creatingAccountProcessing =
      'Creating account, please wait';
  static const String alreadyHaveAnAccount = 'Already have an account?';
  static const String termsAndPrivacyPlaceholder =
      'By creating an account, you agree to our Terms of Service and Privacy Policy.';

  // Auth Accessibility Semantics - Register
  static const String showConfirmPasswordSemantics = 'Show confirm password';
  static const String hideConfirmPasswordSemantics = 'Hide confirm password';

  // Auth Error Messages - Register
  static const String authErrorPasswordTooShort = 'Use at least 8 characters';
  static const String authErrorPasswordTooLong =
      'Password must be 72 characters or fewer';
  static const String authErrorPasswordMismatch = "Passwords don't match";
  static const String authErrorEmailAlreadyRegistered =
      'Check your inbox to continue';
  static const String authErrorRegistrationGeneric =
      'Unable to create account. Please try again.';

  // Auth Screen: Forgot Password ("Reset password")
  static const String resetPasswordTitle = 'Reset password';
  static const String resetPasswordSubtitle =
      "We'll send you a link to reset it";
  static const String emailAddressLabel = 'Email address';
  static const String sendResetLinkAction = 'Send reset link';
  static const String sendingResetLinkProcessing =
      'Sending reset link, please wait';
  static const String backToLogIn = 'Back to log in';
  static const String backToLogInSemantics = 'Back to log in';

  // Forgot Password Confirmation & Cooldown
  static const String checkYourInboxTitle = 'Check your inbox';
  static String resetLinkSentNeutralMessage(String email) =>
      "If an account exists for $email, we've sent a link to reset your password.";
  static const String resendLinkAction = 'Resend link';
  static String resendCooldownAction(int seconds) => 'Resend in $seconds s';
  static const String resetLinkSuccessAnnouncement =
      'Password reset link sent. Please check your inbox.';
  static const String resendAvailableAnnouncement =
      'You can now request a new reset link.';

  // Forgot Password Errors
  static const String authErrorTooManyRequests =
      'Too many requests. Please wait a bit before trying again.';
  static const String authErrorResetGeneric =
      'Unable to send reset link. Please try again.';

  // Main Screen: Path (Home Tab)
  static const String continueOverline = 'CONTINUE';
  static String continueCaption(int minutes) =>
      'About $minutes min · tap to start';
  static const String dueStripNoPhrases =
      'Start your first lesson to build review phrases';
  static const String dueStripNothingDue =
      'Nothing due — your phrases are strong';
  static String dueStripCount(int count) =>
      '$count ${count == 1 ? 'phrase' : 'phrases'} due';
  static const String dueStripReviewAction = 'Review';
  static const String unitGuidebookTooltip = 'Guidebook';
  static String unitOverline(int unit, int done, int total) =>
      'UNIT $unit · $done OF $total STOPS DONE';
  static const String nextTag = 'NEXT';
  static const String freeUnitNote =
      'First unit of every language is free. Unlock the rest, or watch an ad for a free day.';
  static const String offlineBanner =
      "You're offline · practicing from local cache";

  // Locked Node Sheet Placeholders
  static const String lockedNodeSheetTitle = 'Unlock this stop';
  static const String lockedNodeSheetProgressMessage =
      'Pass previous stops to unlock this lesson, or test out now.';
  static const String lockedNodeSheetPremiumMessage =
      'This unit is part of Pebbi Premium. Unlock all units and languages.';
  static const String testOutAction = 'Test out (8 questions)';
  static const String goBackAction = 'Go back';

  // Accessibility Semantics - Path
  static String streakPillSemantics(int days) =>
      'Streak, $days ${days == 1 ? 'day' : 'days'}';
  static String starsPillSemantics(int stars) =>
      'Stars, $stars ${stars == 1 ? 'star' : 'stars'}';
  static String languagePillSemantics(String language) =>
      'Language, $language, double tap to change';
  static const String profileButtonSemantics = 'Profile and settings';

  // Path aliases & extra copy
  static const String levelHintLittle =
      'Little mode · tap your profile to change it';
  static const String freeUnitNoteTitle =
      'First unit of every language is free';
  static const String freeUnitNoteSubtitle =
      'Unlock full access to explore further.';
  static const String continueLessonOverline = continueOverline;
  static const String dueStripZeroPhrases = dueStripNoPhrases;
  static const String dueStripCountDue = 'due for review';
  static const String reviewButton = dueStripReviewAction;
  static const String unitHeaderPrefix = 'UNIT';
  static const String unitHeaderStopsOf = 'OF';
  static const String unitHeaderStopsDone = 'STOPS DONE';
  static const String guidebookTooltip = unitGuidebookTooltip;
  static const String lockedNodeSheetDescription =
      lockedNodeSheetProgressMessage;
  static const String lockedNodeTestOutAction = testOutAction;
  static const String lockedNodeGoBackAction = goBackAction;

  // Missions Tab Screen Strings
  static const String missionsTitle = 'Real life, practised';
  static const String missionsSubtitle =
      'Rehearse the moment before it happens to you.';
  static const String todaysMissionOverline = "TODAY'S MISSION";
  static const String situationsTitle = 'Situations';

  static String todaysMissionAboutMinutes(int minutes) => 'about $minutes min';
  static String missionDurationMinutes(int minutes) => '$minutes min';

  static const String emergencyPhrasebook = 'Emergency\nphrasebook';
  static const String emergencyPhrasebookLabel = 'Emergency phrasebook';
  static const String emergencyPhrasebookQuickActionSubtitle = 'Works offline';
  static const String freeTalk = 'Free talk';
  static const String freeTalkSubtitle = 'Open conversation';

  static const String missionTagNew = 'new';
  static const String missionTagDone = 'done';
  static const String missionTagInProgress = 'in progress';
  static const String missionTagPremium = 'Premium';

  static const String offlineBannerNotice =
      'Offline mode · Missions require internet';
  static const String offlineMissionBlockedTitle = 'Internet required';
  static const String offlineMissionBlockedMessage =
      'Role-play missions run through an AI service and need an active internet connection. Please reconnect and try again.';
  static const String emptyMissionsTitle = 'No situations found';
  static const String emptyMissionsSubtitle =
      'No role-play scenes are currently available for this category or language.';
  static const String selectScenePrompt =
      'Select a situation to view its brief';
  static const String missionBriefPlaceholderTitle = 'Mission Brief';
  static const String missionBriefPlaceholderSubtitle =
      'AI role-play goals, hints, and speech settings will appear here.';
  static const String startPractice = 'Start practice';

  static String categoryFilterLiveAnnouncement(int count) =>
      count == 1 ? 'Showing 1 situation' : 'Showing $count situations';

  static String missionTileSemantics({
    required String title,
    required String characterName,
    required String characterRole,
    required int minutes,
    required int difficulty,
    required int totalDifficulty,
    required String status,
    bool isLocked = false,
  }) {
    final lockSuffix = isLocked ? ', locked, requires Premium' : '';
    return '$title, with $characterName, $characterRole, $minutes minutes, difficulty $difficulty of $totalDifficulty, $status$lockSuffix. Double tap to start.';
  }

  static String todaysMissionSemantics({
    required String title,
    required String characterName,
    required String characterRole,
    required int minutes,
  }) {
    return "Today's mission: $title, with $characterName, $characterRole, about $minutes minutes. Double tap to start.";
  }

  static const String emergencyPhrasebookSemantics =
      'Emergency phrasebook, works without internet. Double tap to open.';
  static const String freeTalkSemantics =
      'Free talk, open conversation. Double tap to start.';

  // Emergency Phrasebook Screen Strings
  static const String emergencyPhrasebookTitle = 'Emergency phrasebook';
  static const String emergencyPhrasebookSubtitle =
      'Tap a card, then show your screen. Works with no connection.';
  static const String emergencyHeaderTitle = 'Emergency phrasebook';
  static const String emergencyHeaderSubtitle =
      'Tap a card, then show your screen. Works with no connection.';
  static const String backToMissions = 'Back to missions';
  static const String emergencyBackToMissions = 'Back to missions';
  static const String missionsLink = 'Missions';
  static const String emergencyAudioUnavailableOffline =
      "Audio isn't available offline for this language.";
  static const String emergencyOfflineVoiceUnavailable =
      "Audio isn't available offline for this language.";
  static const String emergencyPhrasesNotReadyTitle =
      "Emergency phrases for this language aren't ready yet";
  static const String emergencyPhrasesNotReadySubtitle =
      'Native-speaker reviewed emergency translations are being prepared. Check back soon.';
  static const String playPhrase = 'Play phrase';
  static const String playingPhrase = 'Playing phrase';
  static const String close = 'Close';

  static String emergencyNoteMessage(String languageName) =>
      "Phrases are for the language you're learning ($languageName). Check your local emergency number for the country you're in — Pebbi doesn't guess numbers.";

  static String emergencyPhraseCardSemantics({
    required String meaning,
    required String languageName,
    required String phrase,
  }) => '$meaning. In $languageName: $phrase. Double tap to show full screen.';

  // Free Talk Screen Strings
  static const String freeTalkScreenTitle =
      'What do you feel like talking about?';
  static String freeTalkScreenSubtitle(String targetLanguageName) =>
      'Any topic. Pebbi keeps the $targetLanguageName at your level.';
  static const String correctionStyleLabel = 'CORRECTION STYLE';
  static const String correctionStyleGentle = 'Gentle';
  static const String correctionStyleLive = 'Live';
  static const String correctionStyleNone = 'None';
  static const String correctionHelperGentle =
      'Fixes come at the end, in the debrief.';
  static const String correctionHelperLive =
      'Fixes appear in real time as you chat.';
  static const String correctionHelperNone =
      'Chat freely without any corrections.';

  // Custom Topic ("My own") Strings
  static const String customTopicSheetTitle = 'Choose your topic';
  static const String customTopicFieldLabel =
      'What would you like to talk about?';
  static const String customTopicFieldHint =
      'e.g., Space exploration, street food...';
  static const String customTopicStart = 'Start talking';
  static const String customTopicValidationEmpty =
      'Please enter a topic to talk about.';
  static const String customTopicMaxLengthError =
      'Topic is too long (maximum 60 characters).';

  // Free Talk State & Access Strings
  static const String freeTalkOfflineNotice =
      'Offline mode · Free talk requires internet';
  static const String freeTalkLanguageUnsupported =
      "Free talk isn't available for this language yet";
  static const String freeTalkStartTalking = 'Start talking';

  static String topicChipSemantics({
    required String topic,
    required bool isCustom,
  }) {
    if (isCustom) {
      return '$topic topic. Double tap to type your topic.';
    }
    return '$topic, topic. Double tap to start talking.';
  }

  static String correctionStyleSemantics({
    required String style,
    required bool isSelected,
  }) {
    return '$style, ${isSelected ? 'selected' : 'not selected'}';
  }

  // Review Tab Strings
  static const String reviewTitle = "Phrases you've learned";
  static const String reviewSubtitle =
      'Short and sweet: practice takes about 2 minutes.';
  static const String addPhraseTooltip = 'Add a phrase';

  // Review Segmented Tabs
  static const String reviewSegmentPhrases = 'Phrases';
  static const String reviewSegmentPractice = 'Practice';
  static const String reviewSegmentLibrary = 'Library';
  static String reviewSegmentSemantics({
    required String label,
    required int index,
    required int total,
    required bool isSelected,
  }) => '$label, tab $index of $total${isSelected ? ', selected' : ''}';

  // Invite A Friend Card
  static const String inviteCardTitle = 'Invite a friend';
  static const String inviteCardSubtitle =
      'Languages stick faster when someone learns beside you.';
  static const String inviteLinkSemantics = 'Invite link';
  static const String inviteCopyAction = 'Copy';
  static const String inviteCopiedAction = 'Copied';
  static const String inviteCopiedAnnouncement =
      'Invite link copied to clipboard';
  static const String inviteShareAction = 'Share the invite';
  static const String inviteShareSubject = 'Learn languages with me on Pebbi!';
  static String inviteDefaultShareText(String url) =>
      'Join me on Pebbi to speak languages for real! $url';
  static const String inviteLinkUnavailable = 'Invite link unavailable offline';

  // Practise Tricky Phrases
  static const String practiseTrickyPhrasesAction = 'Practise tricky phrases';
  static const String practiseTrickyNoPhrasesMessage =
      'No tricky phrases right now · Keep learning on the Path!';

  // Phrase Filter Chips
  static const String phraseFilterAll = 'All';
  static const String phraseFilterTricky = 'Tricky';
  static const String phraseFilterNew = 'New';
  static const String phraseFilterSaved = 'Saved';
  static String phraseFilterSemantics({
    required String label,
    required bool isSelected,
  }) => '$label filter${isSelected ? ', selected' : ''}';

  // Phrases Empty States
  static const String phrasesEmptyTitle = 'No phrases yet';
  static const String phrasesEmptySubtitle =
      'Finish your first stop and every phrase you meet lands here.';
  static const String phrasesEmptyTrickyTitle = 'Nothing tricky right now';
  static const String phrasesEmptyTrickySubtitle =
      'Phrases you get wrong during practice will appear here for focused review.';
  static const String phrasesEmptyNewTitle = 'No new phrases';
  static const String phrasesEmptyNewSubtitle =
      "New phrases from lessons will show up here until they're mastered.";
  static const String phrasesEmptySavedTitle = 'No saved phrases';
  static const String phrasesEmptySavedSubtitle =
      'Tap the star on any phrase to save it to your phrasebook.';
  static String phrasesMetCount(int count) =>
      '$count ${count == 1 ? 'phrase' : 'phrases'} met so far';

  // Add Phrase Sheet
  static const String addPhraseSheetTitle = 'Add a phrase';
  static const String addPhraseFieldLabel = 'What did you hear or read?';
  static const String addPhraseFieldHint = 'e.g., Un café por favor...';
  static const String addPhraseTranslateAction = 'Translate';
  static const String addPhraseOfflineNotice =
      'Translating new phrases requires an internet connection.';
  static const String addPhraseEmptyError =
      'Please enter a phrase to translate.';

  // Phrase Detail Sheet
  static const String phraseDetailTitle = 'Phrase details';
  static const String phraseDetailSpacedRepetitionNotice =
      'Spaced repetition details and history will appear here.';
  static const String phraseDetailBookmarkAction = 'Bookmark phrase';
  static const String phraseDetailRemoveBookmarkAction = 'Remove bookmark';

  // Practice Segment Strings
  static const String practiceStartButton = 'Start';
  static String practice2MinTitle(int minutes) => '$minutes-minute practice';
  static const String practice2MinSubtitle = 'Pebbi picks the best mix for you';
  static const String practiceFlashcardsTitle = 'Flashcards';
  static String practiceFlashcardsSubtitle(int count) =>
      '$count ${count == 1 ? 'card' : 'cards'} · flipped both ways';
  static const String practiceTrickyTitle = 'Tricky phrases';
  static String practiceTrickySubtitle(int count) =>
      '$count ${count == 1 ? 'phrase wants' : 'phrases want'} another look';
  static const String practiceComingSoonNote =
      "Listening, Speaking Lab, Stories and Script Lab are the next round of practice rooms — they'll land inside these tiles as they pass native-speaker review.";

  // Practice Availability Notices
  static const String practiceUnlockFirstLesson =
      'Finish your first lesson to unlock practice';
  static const String practiceNoFlashcards =
      'No flashcards yet — learn phrases in lessons first';
  static const String practiceNoTricky =
      'No tricky phrases right now — great job!';

  // Practice Semantics
  static String practiceTileSemantics({
    required String title,
    required String subtitle,
    required bool isStartAction,
  }) => isStartAction
      ? '$title. $subtitle. Double tap to start.'
      : '$title, $subtitle. Double tap to open.';

  // Library Segment Strings
  static const String phrasebookTitle = 'Phrasebook';
  static String phrasebookSavedCount(int count) => '$count saved';
  static const String phrasebookEmptyNote =
      'Nothing saved yet. Tap the star on any phrase — or add one you heard today with the + button.';
  static const String seeAllSavedPhrases = 'See all saved phrases';
  static const String grammarCultureNotesTitle = 'Grammar and culture notes';
  static String grammarCultureNotesSubtitle(
    String languageName,
    String level,
  ) =>
      '$languageName notes for the level you\'re working through. Offline once opened.';
  static const String noteOfflineUnavailableNotice =
      'Connect once to read this note, then it works offline';
  static const String selectNotePrompt = 'Select a note to read';
  static const String emptyNotesTitle = 'No notes yet';
  static const String emptyNotesSubtitle =
      'Grammar and culture notes for this level will appear here.';
  static String noteTileSemantics({
    required String title,
    required String excerpt,
  }) => '$title. $excerpt. Double tap to read.';

  // Star Button Semantics
  static const String savePhraseSemantics = 'Save phrase';
  static const String savedPhraseSemantics = 'Saved, double tap to remove';

  // Placeholders
  static const String practicePlaceholderTitle = 'Practice';
  static const String practicePlaceholderSubtitle =
      '2-minute mix, flashcards, and speed review are on the way.';
  static const String libraryPlaceholderTitle = 'Library';
  static const String libraryPlaceholderSubtitle =
      'Saved phrasebook, grammar and culture notes will appear here.';
  static const String selectPhrasePrompt =
      'Select a phrase to view details and practice history';

  // Review Tab Aliases and Convenience Getters
  static const String reviewPhrasesLearnedTitle = reviewTitle;
  static const String reviewPhrasesLearnedSubtitle = reviewSubtitle;
  static const String tabPhrases = reviewSegmentPhrases;
  static const String tabPractice = reviewSegmentPractice;
  static const String tabLibrary = reviewSegmentLibrary;
  static const String inviteCopy = inviteCopyAction;
  static const String inviteCopied = inviteCopiedAction;
  static const String copiedToClipboard = inviteCopiedAnnouncement;
  static const String copyInviteLink = inviteLinkSemantics;
  static const String inviteShareButton = inviteShareAction;
  static const String practiseTrickyPhrasesButton = practiseTrickyPhrasesAction;
  static const String filterAll = phraseFilterAll;
  static const String filterTricky = phraseFilterTricky;
  static const String filterNew = phraseFilterNew;
  static const String filterSaved = phraseFilterSaved;
  static const String reviewEmptyTitle = phrasesEmptyTitle;
  static const String reviewEmptySubtitle = phrasesEmptySubtitle;
  static String emptyFilterTitle(String filterName) => 'No $filterName phrases';
  static const String emptyFilterSubtitle =
      'Phrases matching this filter will appear here as you practice.';
  static const String practicePlaceholderDescription =
      practicePlaceholderSubtitle;
  static const String libraryPlaceholderDescription =
      libraryPlaceholderSubtitle;
  static const String backToReview = 'Review';
  static const String unsavePhraseAction = 'Unsave phrase';
  static const String savePhraseAction = 'Save phrase';
  static const String savePhraseToBook = 'Save to phrasebook';
  static const String phraseStatusTricky = 'Tricky';
  static const String phraseStatusNew = 'New';
  static const String phraseStatusMastered = 'Mastered';
  static const String translationRequiresInternet = addPhraseOfflineNotice;
  static const String translationFailed =
      'Translation failed. Please try again.';
  static const String phraseSavedSuccess = 'Phrase saved to your phrasebook!';
  static const String addPhraseHint = addPhraseFieldHint;
  static const String addPhraseSheetSubtitle =
      'Type in your native language or Spanish to translate and save.';
  static const String translating = 'Translating...';
  static const String translateAction = addPhraseTranslateAction;

  // Rewards Screen Localization Strings
  static const String rewardsTitle = 'Your progress';
  static String rewardsSubtitle(String language, int level, String outfit) =>
      '$language · level $level · $outfit';
  static const String rewardsSettingsSemantics = 'Settings';

  static const String rewardsStopsDoneLabel = 'stops done';
  static const String rewardsPhrasesLabel = 'phrases';
  static const String rewardsStarsLabel = 'stars';

  static String rewardsDailyGoalTitle(int lessonCount) => lessonCount == 1
      ? 'Daily goal: 1 lesson'
      : 'Daily goal: $lessonCount lessons';
  static const String rewardsDailyGoalMissed =
      'Missed a day? No problem. Pebbi will be right here.';
  static const String rewardsDailyGoalDone = 'Done today — nicely done!';
  static String rewardsReminderSet(String formattedTime) =>
      'Reminder set for $formattedTime';
  static String rewardsLevelCaption(int level) => 'Level $level';
  static String rewardsNextLevelCaption(int nextLevel, int stars) =>
      'Level $nextLevel at $stars stars';
  static const String rewardsTopLevel = 'Top level';
  static String rewardsGoalSemantics(int done, int target) =>
      'Daily goal, $done of $target ${target == 1 ? "lesson" : "lessons"} done';
  static String rewardsLevelProgressSemantics(
    int level,
    int stars,
    int? targetStars,
  ) => targetStars != null
      ? 'Level $level, $stars of $targetStars stars'
      : 'Level $level, Top level with $stars stars';

  static String rewardsStreakTitle(int days) =>
      days == 1 ? '1 day streak' : '$days days streak';
  static String rewardsStreakSubtitle(int activeDays, int freezes) =>
      '${activeDays == 1 ? "1 active day" : "$activeDays active days"} · ${freezes == 1 ? "1 freeze ready" : "$freezes freezes ready"}';
  static const String rewardsCalendarPill = 'calendar';
  static String rewardsStreakSemantics(
    int streakDays,
    int activeDays,
    int freezes,
  ) =>
      '${streakDays == 1 ? "1 day streak" : "$streakDays days streak"}, ${activeDays == 1 ? "1 active day" : "$activeDays active days"}, ${freezes == 1 ? "1 freeze ready" : "$freezes freezes ready"}';

  static const String rewardsLast4WeeksTitle = 'Last 4 weeks';
  static const String rewardsCalendarRepairNote =
      'Repair a missed day with a 2-minute warm-up — never by paying.';
  static String rewardsCalendarSemantics(int activeDays) =>
      'Last 4 weeks, ${activeDays == 1 ? "1 active day" : "$activeDays active days"}';
  static String rewardsCalendarCellSemantics(
    int day,
    String stateDescription,
  ) => '$day, $stateDescription';

  static const String rewardsQuestsTitle = 'Quests';
  static String rewardsQuestsDone(int done, int total) => '$done/$total done';
  static const String rewardsChestNote =
      'Finish all four and the weekly chest opens with a sticker inside.';
  static String rewardsQuestSemantics(String label, int current, int target) =>
      '$label, $current of $target';

  static const String rewardsBadgesTitle = 'Badges';
  static String rewardsBadgesEarnedCount(int count) => '$count earned';
  static const String rewardsBadgeLocked = 'locked';
  static const String rewardsBadgeInProgress = 'in progress';
  static const String rewardsBadgeEarned = 'earned';
  static String rewardsBadgeEarnedOn(String date) => 'Earned $date';
  static String rewardsBadgeSemanticsLocked(String name, String howToEarn) =>
      '$name, locked. $howToEarn. Double tap for details.';
  static String rewardsBadgeSemanticsInProgress(
    String name,
    int current,
    int target,
  ) => '$name, in progress, $current of $target. Double tap for details.';
  static String rewardsBadgeSemanticsEarned(String name, String? date) =>
      date != null
      ? '$name, earned on $date. Double tap for details.'
      : '$name, earned. Double tap for details.';

  static String rewardsStickerBookButton(int count) =>
      'Open the sticker book ($count)';
  static const String rewardsNextChapterNote =
      'Skill map and certificates are the next chapter — your progress is already saved for them.';
  static const String rewardsStickerBookPlaceholderTitle = 'Sticker book';
  static const String rewardsStickerBookPlaceholderSubtitle =
      'Your collected stickers will live here.';
  static const String rewardsSettingsPlaceholderTitle = 'Settings';
  static const String rewardsSettingsPlaceholderSubtitle =
      'App settings will live here.';
  static const String rewardsBadgeDetailTitle = 'Badge details';
  static const String rewardsBadgeDetailClose = 'Close';

  // Settings Tab Strings
  static const String settingsBackToPath = 'Back to the path';
  static const String settingsFirstNamePlaceholder = 'Your first name';
  static String settingsSubtitle(String language, String level) =>
      '$language learner · $level mode';

  // Settings Courses Card
  static const String settingsCoursesTitle = 'Courses';
  static const String settingsCoursesSubtitle =
      "Switch language, level or the language of explanations. Nothing you've finished is ever lost.";
  static const String settingsExplanationsInTitle = 'Explanations in';
  static const String settingsExplanationsInSubtitle =
      "Used for Pebbi's notes and mission feedback";
  static const String settingsShowHelperLineTitle = 'Show helper line';
  static const String settingsShowHelperLineSubtitle =
      'Romanization, pinyin or transliteration under target text';
  static const String settingsExplanationSheetTitle = 'Explanations in';
  static const String settingsSearchLanguagePlaceholder = 'Search language';

  // Settings Goal and Reminders Card
  static const String settingsGoalRemindersTitle = 'Goal and reminders';
  static const String settingsGoalRemindersSubtitle =
      'One nudge a day at most, and quiet hours are respected.';
  static const String settingsReminderTimeTitle = 'Reminder time';
  static const String settingsPebbiNudgesTitle = 'Pebbi nudges me';
  static const String settingsPebbiNudgesSubtitle =
      'Turn the daily reminder off entirely';

  // Settings Sound and Haptics Card
  static const String settingsSoundHapticsTitle = 'Sound and haptics';
  static const String settingsSoundEffectsTitle = 'Sound effects';
  static const String settingsHapticsTitle = 'Haptics';
  static const String settingsHapticsSubtitle =
      'Gentle ticks on tap, correct and wrong';
  static const String settingsAutoplayTitle = 'Autoplay audio';
  static const String settingsAutoplaySubtitle =
      'Plays new phrases as soon as they appear';
  static const String settingsSpeakingTitle = 'Speaking practice';
  static const String settingsSpeakingSubtitle =
      'Off keeps every speaking task in self-check mode';
  static const String settingsTestSoundTitle = 'Test the sound';
  static const String settingsSoundEffectsOffMessage = 'Sound effects are off';

  // Settings Appearance Card
  static const String settingsAppearanceTitle = 'Appearance';
  static const String settingsAppearanceSubtitle =
      'Light, dark or follow your phone.';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsThemeSystem = 'System';
  static const String settingsTextSizeLabel = 'Text size';
  static String settingsTextSizePercent(int percent) => '$percent%';
  static String settingsThemeAnnouncement(String mode) => '$mode theme on';
  static String settingsAccentAnnouncement(String name) =>
      'Accent colour $name';

  // Settings Accessibility Card
  static const String settingsAccessibilityTitle = 'Accessibility';
  static const String settingsAccessibilitySubtitle =
      'Every animation becomes a soft fade when you ask for less motion.';
  static const String settingsReduceMotionTitle = 'Reduce motion';
  static const String settingsCaptionsTitle = 'Captions always on';
  static const String settingsCaptionsSubtitle =
      'Target text plus a meaning line in missions';
  static const String settingsLeftHandedTitle = 'Check button on the left';
  static const String settingsLeftHandedSubtitle =
      'Moves the Check and Continue buttons for left-handed use';

  // Settings Account Card
  static const String settingsAccountTitle = 'Account';
  static const String settingsAccountSubtitle =
      "Pebbi works without an account while you're finding your feet.";
  static const String settingsGuestModeTitle = 'Guest mode';
  static const String settingsGuestModeSubtitle =
      'Your streak, stars and phrasebook live on this device.';
  static const String settingsSignInTitle = 'Sign in and sync';
  static const String settingsSignInSubtitle =
      'Keep your stars, streak and phrasebook on every device.';
  static const String settingsSignInAction = 'Sign in';
  static const String settingsFreePlanTitle = 'Free plan';
  static const String settingsFreePlanSubtitle =
      'The first unit of every language is always free';
  static const String settingsSeeOptionsAction = 'See options';
  static const String settingsResetProgressTitle = 'Reset my progress';
  static const String settingsResetProgressSubtitle =
      'Clears everything stored on this device';

  // Settings Reset Dialog
  static const String settingsResetDialogTitle = 'Reset your progress?';
  static const String settingsResetDialogBody =
      'This will permanently delete your streak, stars, phrases, saved items, settings, and answers given in setup for this account on this device. This cannot be undone.';
  static const String settingsResetConfirm = 'Reset';
  static const String settingsResetCancel = 'Cancel';

  // Settings Signed-In / Premium Placeholders
  static const String settingsAccountSignedTitle = 'Account';
  static const String settingsAccountSignedSubtitle =
      'Your progress syncs across devices';
  static const String settingsLogOutAction = 'Log out';
  static const String settingsChangePasswordTitle = 'Change password';
  static const String settingsDeleteAccountTitle = 'Delete account';
  static const String settingsManageSubscriptionAction = 'Manage';

  // Settings More Card & Version
  static const String settingsMoreTitle = 'More';
  static const String settingsPrivacyTitle = 'Privacy and voice data';
  static const String settingsHelpTitle = 'Help and fixes';
  static const String settingsAboutTitle = 'About Pebbi';
  static String settingsVersion(String version) => 'Pebbi · version $version';

  // Settings Sub-route Placeholders
  static const String settingsPrivacyPlaceholderTitle =
      'Privacy and voice data';
  static const String settingsPrivacyPlaceholderSubtitle =
      'Privacy policy, speech recording retention, and AI terms will appear here.';
  static const String settingsHelpPlaceholderTitle = 'Help and fixes';
  static const String settingsHelpPlaceholderSubtitle =
      'Frequently asked questions, diagnostics, and support contact will appear here.';
  static const String settingsAboutPlaceholderTitle = 'About Pebbi';
  static const String settingsAboutPlaceholderSubtitle =
      'Pebbi app version, credits, and open-source licenses will appear here.';
}
