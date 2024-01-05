import 'package:bookstore/Common/Welcome%20Screen/welcome.dart';
import 'package:flutter/material.dart';

class OnBoardClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoard(),
    );
  }
}

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}
class OnBoardingContent{
  String image;
  String title;
  String description;
  OnBoardingContent({required this.image,required this.title,required this.description});
}

List<OnBoardingContent> contents = [
  OnBoardingContent(
    image: 'bookk.png',
    title: 'Verse Vouyage eBookStore',
    description: 'Welcome to Verse Voyage, where literature meets exploration! At Verse Voyage, we embark on a journey through the boundless realms of words and imagination. Our e-bookstore is not just a destination; its a portal to worlds waiting to be discovered, stories yearning to be told, and adventures begging to be experienced.'
  ),
   OnBoardingContent(
    image: 'thinking.png',
    title: 'Thoughtful Books',
    description: 'The mere act of considering a book is an invitation to explore worlds beyond, to delve into the uncharted territories of creativity, wisdom, and emotion. The boundless realm of possibilities lies within the confines of those covers, beckoning you to engage in the transformative power of literature.'
  ),
   OnBoardingContent(
    image: 'discountt.png',
    title: 'Competitive Pricing and Discounts',
    description: 'Providing competitive prices for e-books and occasional discounts can attract more customers. Pricing strategies that take into account market trends and customer expectations can contribute to customer satisfaction and loyalty. '
  )
];
class _OnBoardState extends State<OnBoard> {
  int currentIndex = 0;
  late PageController _controller;
  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller, 
              itemCount: contents.length,
              onPageChanged: (int index){
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_,i){
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Image.asset(contents[i].image, height: 300),
                      SizedBox(height: 10),
                      Text(contents[i].title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),),
                      SizedBox(height: 10),
                      Text(contents[i].description,textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),),
                    ],
                  ),
                );
              }
              ),
          ),
         Container(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(contents.length, 
    (index) => buildDot(index, context),
    ),
  ),
),

          Container(
            margin: EdgeInsets.all(40),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
            color: Color(0xFF24375E),
            borderRadius: BorderRadius.circular(25),
  ),
            child: Material(
            borderRadius: BorderRadius.circular(25),
            color: Colors.transparent,
            child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              if(currentIndex == contents.length -1){
                Navigator.push( context,
                MaterialPageRoute(
                builder: (context) => WelcomePage()),
                );
              }
              _controller.nextPage(duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
             },
            child: Center(
            child: Text(  currentIndex == contents.length -1 ? "Continue" : "Next",
            style: TextStyle(color: Colors.white),
            ),
      ),
    ),
  ),
)

        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 20 : 10,
      margin: EdgeInsets.only(right: 5), // Optional: Add margin between containers
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color(0xFF24375E),
      ),
    );
  }
}