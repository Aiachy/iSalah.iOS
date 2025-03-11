//
//  IslamicPrayerData.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//


import Foundation

struct IslamicPrayerData {
    
    static func getDailyPrayer() -> TodayHadisModel {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        
        let fallbackPrayer = TodayHadisModel(
            id: "default",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6369",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            reading: "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'adhaban-nar",
            meal: "Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire."
        )

        guard let day = dateComponents.day, let month = dateComponents.month else {
            // Fallback to first prayer if we can't get date components
            return prayers.first ?? fallbackPrayer
        }
        
        // Use the day and month to calculate a consistent index
        let index = (day + month - 1) % max(1, prayers.count)
        
        // Return the prayer at the calculated index, or fallback if the array is empty
        return prayers.indices.contains(index) ? prayers[index] : fallbackPrayer
                
    }
        
    static let prayers: [TodayHadisModel] = [
        // 1
        TodayHadisModel(
            id: "1",
            title: "Sahih Bukhari",
            subTitle: "Hadith 1",
            arabic: "رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَآ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ",
            reading: "Rabbana wa-j'alna Muslimayni laka wa min Dhurriyatina 'Ummatan Muslimatan laka wa 'Arina Manasikana wa tub 'alayna 'innaka 'antat-Tawwabu-Raheem",
            meal: "Oh our Lord! Make us Muslims, a people who submit to Your will; and from our descendants, an illiterate Muslim who prostrates himself to Your will; show us our places of worship; and accept our repentance; for You are the Most Repentant, the Most Merciful."
        ),
        
        // 2
        TodayHadisModel(
            id: "2",
            title: "Sahih Muslim",
            subTitle: "Hadith 19",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لَا يَنْفَعُ وَمِنْ قَلْبٍ لَا يَخْشَعُ وَمِنْ نَفْسٍ لَا تَشْبَعُ وَمِنْ دَعْوَةٍ لَا يُسْتَجَابُ لَهَا",
            reading: "Allahumma inni a'udhu bika min 'ilmin la yanfa'u, wa min qalbin la yakhsha'u, wa min nafsin la tashba'u, wa min da'watin la yustajabu laha",
            meal: "O Allah, I seek refuge in You from knowledge that does not benefit, from a heart that does not humble itself, from a soul that is not satisfied, and from a supplication that is not answered."
        ),
        
        // 3
        TodayHadisModel(
            id: "3",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 466",
            arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلاَ إِلَهَ غَيْرُكَ",
            reading: "Subhanaka Allahumma wa bihamdika wa tabaraka ismuka wa ta'ala jadduka wa la ilaha ghairuka",
            meal: "Glory be to You, O Allah, and praise be to You. Blessed is Your name and exalted is Your majesty. There is no god but You."
        ),
        
        // 4
        TodayHadisModel(
            id: "4",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3419",
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى",
            reading: "Allahumma inni as'aluka al-huda wat-tuqa wal-'afafa wal-ghina",
            meal: "O Allah, I ask You for guidance, piety, chastity, and contentment."
        ),
        
        // 5
        TodayHadisModel(
            id: "5",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6369",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            reading: "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'adhaban-nar",
            meal: "Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire."
        ),
        
        // 6
        TodayHadisModel(
            id: "6",
            title: "Sahih Muslim",
            subTitle: "Hadith 2702",
            arabic: "اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ دِقَّهُ وَجِلَّهُ وَأَوَّلَهُ وَآخِرَهُ وَعَلَانِيَتَهُ وَسِرَّهُ",
            reading: "Allahumma-ghfir li dhanbi kullahu, diqqahu wa jillahu, wa awwalahu wa akhirahu, wa 'alaniyatahu wa sirrahu",
            meal: "O Allah, forgive me all my sins, the small and the great, the first and the last, the open and the secret."
        ),
        
        // 7
        TodayHadisModel(
            id: "7",
            title: "Sunan Ibn Majah",
            subTitle: "Hadith 3830",
            arabic: "رَبِّ زِدْنِي عِلْمًا",
            reading: "Rabbi zidni 'ilma",
            meal: "My Lord, increase me in knowledge."
        ),
        
        // 8
        TodayHadisModel(
            id: "8",
            title: "Sahih Bukhari",
            subTitle: "Hadith 2823",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرِّجَالِ",
            reading: "Allahumma inni a'udhu bika minal-hammi wal-hazan, wal-'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala'id-dayn wa ghalabatir-rijal",
            meal: "O Allah, I seek refuge in You from anxiety and sorrow, from weakness and laziness, from miserliness and cowardice, from being overcome by debt and overpowered by men."
        ),
        
        // 9
        TodayHadisModel(
            id: "9",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 5065",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ مَا عَمِلْتُ وَمِنْ شَرِّ مَا لَمْ أَعْمَلْ",
            reading: "Allahumma inni a'udhu bika min sharri ma 'amiltu wa min sharri ma lam a'mal",
            meal: "O Allah, I seek refuge in You from the evil of what I have done and from the evil of what I have not done."
        ),
        
        // 10
        TodayHadisModel(
            id: "10",
            title: "Sahih Muslim",
            subTitle: "Hadith 763",
            arabic: "اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ، اللَّهُمَّ نَقِّنِي مِنْ خَطَايَايَ كَمَا يُنَقَّى الثَّوْبُ الْأَبْيَضُ مِنَ الدَّنَسِ، اللَّهُمَّ اغْسِلْنِي مِنْ خَطَايَايَ بِالثَّلْجِ وَالْمَاءِ وَالْبَرَدِ",
            reading: "Allahumma ba'id bayni wa bayna khatayaya kama ba'adta baynal-mashriqi wal-maghrib. Allahumma naqqini min khatayaya kama yunaqqath-thawbul-abyadu minad-danas. Allahumma-ghsilni min khatayaya bith-thalji wal-ma'i wal-barad",
            meal: "O Allah, distance me from my sins as You have distanced the East from the West. O Allah, cleanse me of my sins as a white garment is cleansed of dirt. O Allah, wash away my sins with snow, water, and hail."
        ),
        
        // 11
        TodayHadisModel(
            id: "11",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3479",
            arabic: "اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِي وَلَا يُقْضَى عَلَيْكَ، إِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ",
            reading: "Allahumma-hdini fiman hadayt, wa 'afini fiman 'afayt, wa tawallani fiman tawallayt, wa barik li fima a'tayt, wa qini sharra ma qadayt, fa'innaka taqdi wa la yuqda 'alayk, innahu la yadhillu man walayt, tabarakta Rabbana wa ta'alayt",
            meal: "O Allah, guide me among those You have guided, pardon me among those You have pardoned, turn to me in friendship among those on whom You have turned in friendship, and bless me in what You have bestowed. Protect me from the evil You have decreed, for You decree and none decree against You. He whom You befriend is not humbled. Blessed are You, our Lord, and Exalted."
        ),
        
        // 12
        TodayHadisModel(
            id: "12",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6307",
            arabic: "اللَّهُمَّ رَبَّ السَّمَوَاتِ وَرَبَّ الْأَرْضِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ",
            reading: "Allahumma Rabbas-samawati wa Rabbal-ard wa Rabbal-'arshil-'azim, Rabbana wa Rabba kulli shay'in, faliqal-habbi wan-nawa, wa munzilat-Tawrati wal-Injili wal-Furqan, a'udhu bika min sharri kulli shay'in anta akhidhun bi nasiyatihi",
            meal: "O Allah, Lord of the heavens and Lord of the earth and Lord of the Magnificent Throne, our Lord and the Lord of everything, Splitter of the grain and date-stone, Revealer of the Torah, the Gospel and the Criterion (Quran), I seek refuge in You from the evil of everything that You grasp by its forelock."
        ),
        
        // 13
        TodayHadisModel(
            id: "13",
            title: "Sahih Muslim",
            subTitle: "Hadith 2696",
            arabic: "اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ، وَارْحَمْنِي، إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ",
            reading: "Allahumma inni zalamtu nafsi zulman kathiran, wa la yaghfirudh-dhunuba illa anta, faghfir li maghfiratan min 'indika, warhamni, innaka antal-Ghafur-ur-Rahim",
            meal: "O Allah, I have wronged myself greatly, and none forgives sins but You, so forgive me with forgiveness from You and have mercy on me. Surely, You are the Most Forgiving, the Most Merciful."
        ),
        
        // 14
        TodayHadisModel(
            id: "14",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 1544",
            arabic: "اللَّهُمَّ رَبَّنَا لَكَ الْحَمْدُ مِلْءَ السَّمَوَاتِ وَمِلْءَ الْأَرْضِ وَمِلْءَ مَا شِئْتَ مِنْ شَيْءٍ بَعْدُ",
            reading: "Allahumma Rabbana lakal-hamdu mil'as-samawati wa mil'al-ardi wa mil'a ma shi'ta min shay'in ba'du",
            meal: "O Allah, our Lord, to You belongs all praise, filling the heavens and filling the earth and filling whatever else You wish."
        ),
        
        // 15
        TodayHadisModel(
            id: "15",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3575",
            arabic: "لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ",
            reading: "La ilaha illallahul-'Azimul-Halim, la ilaha illallahu Rabbul-'Arshil-'Azim, la ilaha illallahu Rabbus-samawati wa Rabbul-ardi wa Rabbul-'Arshil-Karim",
            meal: "There is no god but Allah, the Great, the Forbearing. There is no god but Allah, the Lord of the Magnificent Throne. There is no god but Allah, the Lord of the heavens and the Lord of the earth and the Lord of the Noble Throne."
        ),
        
        // 16
        TodayHadisModel(
            id: "16",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6399",
            arabic: "اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ",
            reading: "Allahumma 'alimal-ghaybi wash-shahadati fatiras-samawati wal-ard, Rabba kulli shay'in wa malikahu, ashhadu an la ilaha illa anta, a'udhu bika min sharri nafsi, wa min sharrish-shaytani wa shirkihi",
            meal: "O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of everything, I bear witness that there is no god but You. I seek refuge in You from the evil of my soul and from the evil of Satan and his polytheism."
        ),
        
        // 17
        TodayHadisModel(
            id: "17",
            title: "Sahih Muslim",
            subTitle: "Hadith 2722",
            arabic: "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
            reading: "Ya muqallibal-qulubi thabbit qalbi 'ala dinika",
            meal: "O Turner of hearts, make my heart firm upon Your religion."
        ),
        
        // 18
        TodayHadisModel(
            id: "18",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 1510",
            arabic: "اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الْحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ الْمَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ",
            reading: "Allahumma aslih li dini alladhi huwa 'ismatu amri, wa aslih li dunyaya allati fiha ma'ashi, wa aslih li akhirati allati fiha ma'adi, waj'alil-hayata ziyadatan li fi kulli khayr, waj'alil-mawta rahatan li min kulli sharr",
            meal: "O Allah, set right for me my religion which is the safeguard of my affairs. And set right for me the affairs of my world wherein is my living. And set right for me my Hereafter to which is my return. And make the life for me an increase in every good and make death a relief for me from every evil."
        ),
        
        // 19
        TodayHadisModel(
            id: "19",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3551",
            arabic: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
            reading: "Hasbiyallahu la ilaha illa huwa 'alayhi tawakkaltu wa huwa Rabbul-'Arshil-'Azim",
            meal: "Allah is sufficient for me. There is no god but He. I have placed my trust in Him, and He is the Lord of the Magnificent Throne."
        ),
        
        // 20
        TodayHadisModel(
            id: "20",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6401",
            arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
            reading: "A'udhu bikalimatillahit-tammati min sharri ma khalaq",
            meal: "I seek refuge in the perfect words of Allah from the evil of what He has created."
        ),
        
        // 21
        TodayHadisModel(
            id: "21",
            title: "Sahih Muslim",
            subTitle: "Hadith 2078",
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَسْأَلَةِ، وَخَيْرَ الدُّعَاءِ، وَخَيْرَ النَّجَاحِ، وَخَيْرَ الْعَمَلِ، وَخَيْرَ الثَّوَابِ، وَخَيْرَ الْحَيَاةِ، وَخَيْرَ الْمَمَاتِ، وَثَبِّتْنِي، وَثَقِّلْ مَوَازِينِي، وَحَقِّقْ إِيمَانِي، وَارْفَعْ دَرَجَاتِي، وَتَقَبَّلْ صَلَاتِي، وَاغْفِرْ خَطِيئَتِي، وَأَسْأَلُكَ الدَّرَجَاتِ الْعُلَى مِنَ الْجَنَّةِ",
            reading: "Allahumma inni as'aluka khayral-mas'alati, wa khayrad-du'a'i, wa khayran-najahi, wa khayral-'amali, wa khayrath-thawabi, wa khayral-hayati, wa khayral-mamati, wa thabbitni, wa thaqqil mawazini, wa haqqiq imani, warfa' darajati, wa taqabbal salati, waghfir khati'ati, wa as'alukadd-darajatil-'ula minal-jannati",
            meal: "O Allah, I ask You for the best of requests and the best of supplications, the best of success, the best of actions, the best of rewards, the best of life, the best of death. Make me steadfast, make my scale of good deeds heavy, confirm my faith, elevate my rank, accept my prayer, forgive my sin, and I ask You for the highest ranks in Paradise."
        ),
        
        // 22
        TodayHadisModel(
            id: "22",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 5090",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ جَهْدِ الْبَلَاءِ، وَدَرَكِ الشَّقَاءِ، وَسُوءِ الْقَضَاءِ، وَشَمَاتَةِ الْأَعْدَاءِ",
            reading: "Allahumma inni a'udhu bika min jahdil-bala'i, wa darakish-shaqa'i, wa su'il-qada'i, wa shamatati-l-a'da'i",
            meal: "O Allah, I seek refuge in You from the difficulty of tribulation, from the overtaking of misery, from bad destiny, and from the gloating of enemies."
        ),
        
        // 23
        TodayHadisModel(
            id: "23",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3566",
            arabic: "اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ",
            reading: "Allahumma rahmataka arju fa la takilni ila nafsi tarfata 'aynin, wa aslih li sha'ni kullahu, la ilaha illa anta",
            meal: "O Allah, I hope for Your mercy, so do not leave me to myself even for the blink of an eye, and set right all my affairs. There is no god but You."
        ),
        
        // 24
        TodayHadisModel(
            id: "24",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6368",
            arabic: "رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
            reading: "Rabbighfir li wa liwalidayya wa lil-mu'minina yawma yaqumul-hisab",
            meal: "My Lord, forgive me and my parents and the believers on the Day when the reckoning will be established."
        ),
        
        // 25
        TodayHadisModel(
            id: "25",
            title: "Sahih Muslim",
            subTitle: "Hadith 2725",
            arabic: "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ",
            reading: "Allahumma-kfini bi halalika 'an haramika, wa aghnini bi fadlika 'amman siwaka",
            meal: "O Allah, suffice me with what You have allowed instead of what You have forbidden, and make me independent of all others with Your bounty."
        ),
        
        // 26
        TodayHadisModel(
            id: "26",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 1554",
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ",
            reading: "Allahumma inni as'alukal-jannata wa a'udhu bika minan-nar",
            meal: "O Allah, I ask You for Paradise and seek refuge in You from the Fire."
        ),
        
        // 27
        TodayHadisModel(
            id: "27",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3409",
            arabic: "اللَّهُمَّ أَلْهِمْنِي رُشْدِي، وَأَعِذْنِي مِنْ شَرِّ نَفْسِي",
            reading: "Allahumma alhimni rushdi, wa a'idhni min sharri nafsi",
            meal: "O Allah, inspire me with guidance and protect me from the evil of my soul."
        ),
        
        // 28
        TodayHadisModel(
            id: "28",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6390",
            arabic: "اللّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الكَسَلِ والهَرَمِ، والمَأثَمِ والمَغرَمِ، وَمِنْ فِتْنَةِ القَبْرِ وَعَذَابِ القَبْرِ، وَمِنْ فِتْنَةِ النَّارِ وَعَذَابِ النَّارِ، وَمِنْ شَرِّ فِتْنَةِ الغِنَى، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الفَقْرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ المَسِيحِ الدَّجَّالِ",
            reading: "Allahumma inni a'udhu bika minal-kasali wal-harami, wal-ma'thami wal-maghrami, wa min fitnatil-qabri wa 'adhabil-qabri, wa min fitnatil-nari wa 'adhabin-nari, wa min sharri fitnatil-ghina, wa a'udhu bika min fitnatil-faqri, wa a'udhu bika min fitnatil-masihid-dajjal",
            meal: "O Allah, I seek refuge in You from laziness and old age, from sin and debt, from the trial and punishment of the grave, from the trial and punishment of the Fire, from the evil of the trial of wealth, and I seek refuge in You from the trial of poverty, and I seek refuge in You from the trial of the False Messiah."
        ),
        
        // 29
        TodayHadisModel(
            id: "29",
            title: "Sahih Muslim",
            subTitle: "Hadith 2739",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْبُخْلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَى أَرْذَلِ الْعُمُرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الدُّنْيَا، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ",
            reading: "Allahumma inni a'udhu bika minal-bukhli, wa a'udhu bika minal-jubni, wa a'udhu bika min an uradda ila ardhalil-'umuri, wa a'udhu bika min fitnatid-dunya, wa a'udhu bika min 'adhabil-qabri",
            meal: "O Allah, I seek refuge in You from miserliness, and I seek refuge in You from cowardice, and I seek refuge in You from being returned to decrepit old age, and I seek refuge in You from the trials of the world, and I seek refuge in You from the punishment of the grave."
        ),
        
        // 30
        TodayHadisModel(
            id: "30",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 5088",
            arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لَا يَنْفَعُ، وَقَلْبٍ لَا يَخْشَعُ، وَنَفْسٍ لَا تَشْبَعُ، وَدُعَاءٍ لَا يُسْمَعُ",
            reading: "Allahumma inni a'udhu bika min 'ilmin la yanfa'u, wa qalbin la yakhsha'u, wa nafsin la tashba'u, wa du'a'in la yusma'u",
            meal: "O Allah, I seek refuge in You from knowledge that does not benefit, from a heart that does not humble itself, from a soul that is not satisfied, and from a supplication that is not heard."
        ),
        
        // 31
        TodayHadisModel(
            id: "31",
            title: "Sunan Ibn Majah",
            subTitle: "Hadith 3831",
            arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا",
            reading: "Allahumma inni as'aluka 'ilman nafi'an, wa rizqan tayyiban, wa 'amalan mutaqabbalan",
            meal: "O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds."
        ),
        
        // 32
        TodayHadisModel(
            id: "32",
            title: "Sahih Bukhari",
            subTitle: "Hadith 4438",
            arabic: "اللَّهُمَّ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            reading: "Allahumma Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'adhaban-nar",
            meal: "O Allah, our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire."
        ),
        
        // 33
        TodayHadisModel(
            id: "33",
            title: "Sahih Muslim",
            subTitle: "Hadith 2086",
            arabic: "اللَّهُمَّ مُصَرِّفَ الْقُلُوبِ صَرِّفْ قُلُوبَنَا عَلَى طَاعَتِكَ",
            reading: "Allahumma musarrifal-qulubi, sarrif qulubana 'ala ta'atika",
            meal: "O Allah, Turner of hearts, turn our hearts to Your obedience."
        ),
        
        // 34
        TodayHadisModel(
            id: "34",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3615",
            arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
            reading: "Subhanallahi wa bihamdihi, subhanallahil-'Azim",
            meal: "Glory be to Allah and praise be to Him, Glory be to Allah, the Great."
        ),
        
        // 35
        TodayHadisModel(
            id: "35",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6404",
            arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
            reading: "Subhanallahi wa bihamdihi, 'adada khalqihi, wa rida nafsihi, wa zinata 'arshihi, wa midada kalimatihi",
            meal: "Glory be to Allah and praise be to Him, as many as the number of His creation, as pleases Him, as weighs His Throne, and as many as the ink of His words."
        ),
        
        // 36
        TodayHadisModel(
            id: "36",
            title: "Sahih Muslim",
            subTitle: "Hadith 2691",
            arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            reading: "La ilaha illallahu wahdahu la sharika lahu, lahul-mulku wa lahul-hamdu wa huwa 'ala kulli shay'in qadir",
            meal: "There is no god but Allah alone, Who has no partner. His is the dominion and His is the praise, and He is Able to do all things."
        ),
        
        // 37
        TodayHadisModel(
            id: "37",
            title: "Sunan Abu Dawud",
            subTitle: "Hadith 5071",
            arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ",
            reading: "Allahumma salli 'ala Muhammadin wa 'ala ali Muhammadin kama sallayta 'ala Ibrahima wa 'ala ali Ibrahima, innaka Hamidun Majid. Allahumma barik 'ala Muhammadin wa 'ala ali Muhammadin kama barakta 'ala Ibrahima wa 'ala ali Ibrahima, innaka Hamidun Majid",
            meal: "O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim. You are indeed Praiseworthy and Glorious. O Allah, bless Muhammad and the family of Muhammad as You blessed Ibrahim and the family of Ibrahim. You are indeed Praiseworthy and Glorious."
        ),
        
        // 38
        TodayHadisModel(
            id: "38",
            title: "Sahih Bukhari",
            subTitle: "Hadith 6403",
            arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
            reading: "La hawla wa la quwwata illa billah",
            meal: "There is no might and no power except through Allah."
        ),
        
        // 39
        TodayHadisModel(
            id: "39",
            title: "Sahih Muslim",
            subTitle: "Hadith 2706",
            arabic: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ",
            reading: "Ya Hayyu ya Qayyumu bi rahmatika astaghithu",
            meal: "O Ever-Living, O Self-Sustaining and Sustainer of all, by Your mercy I seek help."
        ),
        
        // 40
        TodayHadisModel(
            id: "40",
            title: "Sunan Tirmidhi",
            subTitle: "Hadith 3577",
            arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
            reading: "Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana 'abduka, wa ana 'ala 'ahdika wa wa'dika ma-stata'tu, a'udhu bika min sharri ma sana'tu, abu'u laka bi ni'matika 'alayya, wa abu'u bi dhanbi faghfir li, fa innahu la yaghfirudh-dhunuba illa anta",
            meal: "O Allah, You are my Lord, there is no god but You. You created me and I am Your servant, and I abide by Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge before You Your favor upon me, and I acknowledge my sin, so forgive me, for none forgives sins but You."
        )
    ]
}
