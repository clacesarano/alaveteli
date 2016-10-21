# -*- encoding : utf-8 -*-
Rails.application.config.after_initialize do

    SPAM_PATTERNS =
      [
       /Freedom of Information request - [\{\[\|]/i,
       /Sea?,?s?o?n?[ -.]\d+[ -]Epi?'?s?,?o?d?e?s?[ -.]\d+/i,
       /\[Full-Watch\]/i,
       /free-watch/i,
       /Online Full 2016/i,
       /HD | Special ".*?" Online/i,
       /FULL .O?N?_?L?I?N?E? ?\.?MOVIE/i,
       /\[Full 20x5\]/i,
       /Putlocker/i,
       /se?\d+ep?\d+/i,
       /\[free\]/i,
       /vodlocker/i,
       /online free full/i,
       /streaming 2016/i,
       /films?-?hd/i,
       /full online/i,
       /\[DVDscr\]/i,
       /W@tch/i,
       /720p/i,
       /1080p/i,
       /MEGA.TV/i,
       /1080.HD/i,
       /\[Online-Free\]/i,
       /\[HD\]/i,
       /\{DOWNLOAD\}/i,
       /\(\{Ganzer FIlm\}\)/i,
       /\{leak\}/i,
       /MEGASH[a|e]RE?/i,
       /\[Official.HD\]/i,
       /Completa.*?Ver Online Gratis/i,
       /Assistir.*?Completa Film Portuguese/i,
       /\[MP3\]/i,
       /Watch.*?Movie Online/i,
       /Gratuitement.*?TELECHARGER/i,
       /full album/i,
       /album complet/i,
       /Album.*?Gratuit/i,
       /Free.Download/i,
       /\{FR\}/i,
       /\[Album\]/i,
       /watch.*?online free/i
       ].freeze
end