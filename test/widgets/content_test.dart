import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pancake_app/widgets/content.dart';

import '../utils.dart';

void main() {
  late ImageProvider testImage;

  setUpAll(() async {
    testImage = TestImageProvider(
      await createTestImage(width: 10, height: 10),
    );
  });

  Widget buildTest({String? description, ImageProvider? image}) {
    return MaterialApp(
      home: Center(
        child: Material(
          child: ContentCard(
            onTap: () {},
            description: description ?? '일본의 한 시골 마을에서 여름을 보내게 된다',
            image: image ?? testImage,
          ),
        ),
      ),
    );
  }

  testWidgets('설명은 마우스 이벤트에서 제외된다', (tester) async {
    //given
    await tester.pumpWidget(buildTest(description: '따분한 바다 생활이 싫어'));

    //then
    expect(find.text('따분한 바다 생활이 싫어').hitTestable(), findsNothing);
  });

  testWidgets('카드에 마우스를 올리면 이미지가 흐려지면서 설명이 보여진다', (tester) async {
    //given
    await tester.pumpWidget(buildTest(description: '따분한 바다 생활이 싫어'));
    final mouse = await tester.createMouse();

    //when hovered
    await mouse.moveTo(tester.getCenter(find.contentCard()));
    await tester.pumpAndSettle();
    //then
    expect(tester.opacityByImage(), equals(0.1));
    expect(tester.opacityByDescription('따분한 바다 생활이 싫어'), equals(1.0));

    //when not hovered
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    //then
    expect(tester.opacityByImage(), equals(1.0));
    expect(tester.opacityByDescription('따분한 바다 생활이 싫어'), equals(0.0));
  });

  testWidgets('🐛 카드에 마우스가 빠르게 지나가도 설명은 보여지지 않는다', (tester) async {
    //given
    await tester.pumpWidget(buildTest(description: '따분한 바다 생활이 싫어'));

    //when
    final mouse = await tester.createMouse();
    await mouse.moveTo(tester.getCenter(find.contentCard()));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    //then
    expect(tester.opacityByDescription('따분한 바다 생활이 싫어'), isZero);
  });

  /// 👀 https://github.com/viiviii/friendly-pancake-app/issues/2
  testWidgets('🐛 카드 최하단에 마우스가 위치해도 이벤트가 1번만 발생한다', (tester) async {
    //given
    await tester.pumpWidget(buildTest());

    //when
    final mouse = await tester.createMouse();
    await mouse.moveTo(tester.getBottomRight(find.contentCard()));
    await mouse.moveBy(const Offset(-1, -1));

    //then
    await tester.pumpAndSettle().onError((error, stackTrace) {
      fail(
        '${error.runtimeType}: $error\n'
        '최하단 경계에 마우스 호버 시 슬라이드 애니메이션으로 인해 무한루프가 발생하면 '
        'pumpAndSettle()에서 timed out 에러가 발생한다.\n'
        '$stackTrace',
      );
    });
  });
}

extension _ContentFinder on CommonFinders {
  Finder contentCard() => byType(ContentCard);
}

extension _ContentTester on WidgetTester {
  double opacityByImage() {
    return widget<Image>(find.byType(Image)).opacity!.value;
  }

  double opacityByDescription(String description) {
    return widget<FadeTransition>(find.ancestor(
      of: find.text(description),
      matching: find.byType(FadeTransition),
    )).opacity.value;
  }
}
