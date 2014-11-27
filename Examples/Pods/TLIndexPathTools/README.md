TLIndexPathTools
================

TLIndexPathTools is a small set of classes that can greatly simplify your table and collection views. Here are some of the awesome things TLIndexPathTools does:

* Organize data into sections with ease (now with blocks!)
* Calculate and perform animated batch updates (inserts, moves and deletions)
* Simplify data source and delegate methods via rich data model APIs
* Provide a simpler alternative to Core Data `NSFetchedResultsController`
* Provide base table view and collection view classes with advanced features

TLIndexPathTools is as lightweight as you want it to be. Start small by using `TLIndexPathDataModel` as your data model (instead of an array) and gain the ability to easily organize data into sections and simplify your view controller with APIs like `[dataModel numberOfRowsInSection:]`, `[dataModel itemAtIndexPath:]`, and `[dataModel indexPathForItem:]`. Or keep reading to learn about automatic batch updates, easier Core Data integration and more.

##Installation

Add "TLIndexPathTools" to your podfile or, if you're not using CocoaPods:

1. Download the TLIndexPathTools project
2. Add the TLIndexPathTools sub-folder (sibling of the Examples folder) to your Xcode project.
3. Link to QuartzCore.framework and CoreData.framework (on the Build Phases tab of your project's target).

<!--CoreData is required for Core Data integration and because `TLIndexPathSectionInfo` implements the `NSFetchedResultsSectionInfo` protocol. QuartzCore is required because the Grid extension uses it.-->

##Overview

`NSArray` is the standard construct for simple table and collection view data models. However, if multiple sections are involved, the typical setup is an `NSArray` containing section names and an `NSDictionary` of `NSArrays` containing data items, keyed by section name. Since table and collection views work with `NSIndexPaths`, the following pattern is used repeatedly in data source and delegate methods:

    NSString *sectionName = self.sectionNameArray[indexPath.section];
    NSArray *sectionArray = self.sectionArraysBySectionName[sectionName];    
    id data = sectionArray[indexPath.row];
    
`TLIndexPathDataModel` encapsulates this pattern into a single class and provides numerous APIs for easy data access. Furthermore, the `TLIndexPathDataModel` initializers offer multiple ways to organize raw data into sections (including empty sections). `TLIndexPathDataModel` is perfectly suitable for single-section views where an `NSArray` would suffice and has the benefit of being "refactor proof" if additional sections are added later.

`TLIndexPathUpdates` is a very powerful companion class to `TLIndexPathDataModel`. One of the great things about table and collection views are their ability to perform batch updates (inserts, deletes and moves) that animate cells smoothly between states. However, calculating batch updates can be a complex (and confusing) task when multiple updates are involved. `TLIndexPathUpdates` solves this by taking two versions of your data model, calculating the changes for you and automatically performing the batch updates.

Most of the functionality in TLIndexPathTools can be accomplished with just `TLIndexPathDataModel` and `TLIndexPathUpdates`. However, there are a few of additional components that provide some great features:

* `TLIndexPathController` provides a common programming model for building view controllers that work interchangeably with Core Data `NSFetchRequests` or plain arrays of any data type. One controller to rule them all.
* `TLTableViewController` and `TLCollectionViewController` are table and collection view base classes that use `TLIndexPathController` and implement the essential data source and delegate methods to get you up and running quickly. They also support view controller-backed cells (see the [View Controller Backed][8] sample project) and automatic cell height calculation for table views (see the [Dynamic Height][9] sample project).
* `TLIndexPathItem` is a wrapper class for data items that can simplify working with multiple data types or cell types. For example, take a look at the [Settings sample project][1].
* The `Extensions` folder contains a number of add-ons for things like [collapsable sections][2] and [expandable tree views][3]. This is a good resource to see how `TLIndexPathDataModel` can be easily extended for special data structures.
* And last, but not least, the `Examples` folder contains numerous sample projects demonstrating various use cases and features of the framework. [Shuffle][4] is a good starting point and be sure to try [Core Data][5].

This version of TLIndexPathTools is designed to handle up to a few thousand items. Larger data sets may have performance issues.

###TLIndexPathDataModel

`TLIndexPathDataModel` is an immutable object you use in your view controller to hold your data items instead of an array (or dictionary of arrays, for multiple sections). There are four initializers, a basic one and three for handling multiple sections:

```Objective-C
// single section initializer
TLIndexPathDataModel *dataModel1 = [[TLIndexPathDataModel alloc] initWithItems:items];

// multiple sections defined by a key path property on your data items
TLIndexPathDataModel *dataModel2 = [[TLIndexPathDataModel alloc] initWithItems:items sectionNameKeyPath:@"someKeyPath" identifierKeyPath:nil];

// multiple sections defined by an arbitrary code block
TLIndexPathDataModel *dataModel3 = [[TLIndexPathDataModel alloc] initWithItems:items sectionNameBlock:^NSString *(id item) {
    // organize items by first letter of description (like contacts app)
    return [item.description substringToIndex:1];
} identifierBlock:nil];

// multiple explicitly defined sections (including an empty section)
TLIndexPathSectionInfo *section1 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 1.1"] name:@"Section 1"];
TLIndexPathSectionInfo *section2 = [[TLIndexPathSectionInfo alloc] initWithItems:@[@"Item 2.1", @"Item 2.2"] name:@"Section 2"];
TLIndexPathSectionInfo *section3 = [[TLIndexPathSectionInfo alloc] initWithItems:nil name:@"Section 3"];
TLIndexPathDataModel *dataModel4 = [[TLIndexPathDataModel alloc] initWithSectionInfos:@[section1, section2, section3] identifierKeyPath:nil];
```

And there are numerous APIs to simplify delegate and data source implementations:

```Objective-C
// access all items across all sections as a flat array
dataModel.items;

// access items organized by sections
dataModel.sections;

// number of sections
[dataModel numberOfSections];

// number of rows in section
[dataModel numberOfRowsInSection:section];

// look up item at a given index path
[dataModel itemAtIndexPath:indexPath];

// look up index path for a given item
[dataModel indexPathForItem:item];
```    

As an immutable object, all of the properties and methods in `TLIndexPathDataModel` are read-only. So using the data model is very straightforward once you've selected the appropriate initializer.

###TLIndexPathUpdates

`TLIndexPathUpdates` is a companion class to `TLIndexPathDataModel` for batch updates. You provide two versions of your data model to the initializer and the inserts, deletes, and moves are calculated. Then call either `performBatchUpdatesOnTableView:` or `performBatchUpdatesOnCollectionView:` to perform the updates.

```Objective-C
// initialize collection view with unordered items
// (assuming view controller has a self.dataModel property)
self.dataModel = [[TLIndexPathDataModel alloc] initWithItems:@[@"B", @"A", @"C"]];
[self.collectionView reloadData];

// ...

// sort items, update data model & perform batch updates (perhaps when a sort button it tapped)
TLIndexPathDataModel *oldDataModel = self.dataModel;
NSArray *sortedItems = [self.dataModel.items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
self.dataModel = [[TLIndexPathDataModel alloc] initWithItems:sortedItems];
TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:self.dataModel];
[updates performBatchUpdatesOnCollectionView:self.collectionView];
```

Thats all it takes!

###TLIndexPathController

`TLIndexPathController` is TLIndexPathTools' version of `NSFetchedResultsController`. It should not come as a surprise, then, that you must use this class if you want to integrate with Core Data.

Although it primarily exists for Core Data integration, `TLIndexPathController` works interchangeably with `NSFetchRequest` or plain arrays of any data type. Thus, if you choose to standardize your view controllers on `TLIndexPathController`, it is possible to have a common programming model across all of your table and collection views.

`TLIndexPathController` also makes a few nice improvements relative to `NSFetchedResultsController`:

* Items do not need to be presorted by section. The data model handles organizing sections.
* Changes to your fetch request are animated. So you can get animated sorting and filtering.
* Only one delegate method needs to be implemented (versus five for `NSFetchedResultsController`).

The basic template for using `TLIndexPathController` in a (table) view controller is as follows:

```Objective-C
#import <UIKit/UIKit.h>
#import "TLIndexPathController.h"
@interface ViewController : UITableViewController <TLIndexPathControllerDelegate>
@end

#import "ViewController.h"
@interface ViewController ()
@property (strong, nonatomic) TLIndexPathController *indexPathController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indexPathController = [[TLIndexPathController alloc] init];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    id item = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    //configure cell using data item
    return cell;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}

@end
```

This template works with plain arrays or `NSFetchRequests`. With plain arrays, you simply set the `dataModel` property of the controller (or set the `items` property and get a default data model). With `NSFetchRequests`, you set the `fetchRequest` property and call `performFetch:`. From then on, the controller updates the data model internally every time the fetch results change (using an internal instance of `NSFetchedResultsController` and responding to `controllerDidChangeContent` messages).

In either case, whether you explicitly set a data model or the controller converts a fetch result into a data model, the controller creates the `TLIndexPathUpdates` object for you and passes it to the delegate, giving you an opportunity to perform batch updates:

```Objective-C
- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];    
}
```

The `willUpdateDataModel` delegate method is a really cool feature of `TLIndexPathController`, providing the delegate an opportunity to modify the data model before `didUpdateDataModel` gets called. This can be applied in some interesting ways when integrating with Core Data. For example, it can be used to mix in non-Core Data objects (try doing this with `NSFetchedResultsController`). Another nice application is automatic display of a "No results" message when the data model is empty (the `TLNoResultsTableDataModel` class is provided in the Extensions folder):

```Objective-C
- (TLIndexPathDataModel *)controller:(TLIndexPathController *)controller willUpdateDataModel:(TLIndexPathDataModel *)oldDataModel withDataModel:(TLIndexPathDataModel *)updatedDataModel
{
    if (updatedDataModel.items.count == 0) {
        return [[TLNoResultsTableDataModel alloc] initWithRows:3 blankCellId:@"BlankCell" noResultsCellId:@"NoResultsCell" noResultsText:@"No results to display"];
    }
    return nil;
}
```

###TLTableViewController & TLCollectionViewController

`TLTableViewController` and `TLCollectionViewController` are table and collection view base classes that use `TLIndexPathController` and implement the essential data source and delegate methods to get you up and running quickly. Both classes look much like the code outlined above for integrating with `TLIndexPathController`.

Both classes support view controller-backed cells. Enabling this feature is as easy as overriding the `instantiateViewControllerForCell:` method. For example, see the [View Controller Backed][8] sample project.

`TLTableViewController` also includes a default implementation of `heightForRowAtIndexPath` that calculates static or data-driven cell heights using prototype cell instances. For example, if you're using storyboards, the cell heights specified in the storyboard are automatically used. And if your cell implements the `TLDynamicSizeView` protocol, the height will be determined by calling the `sizeWithData:` method on the prototype cell. This is a great way to handle data-driven height because the `sizeWithData:` method can use the actual layout logic of the cell itself, rather than duplicating the layout logic in the view controller.

Most of the sample projects are based on `TLTableViewController` or `TLCollectionViewController`, so a brief perusal will give you a good idea what can be accomplished with a few lines of code.

##Documentation

The Xcode docset can be generated by running the Docset project. The build configuration assumes [Appledoc][6] is installed at /usr/local/bin/appledoc. This can be changed at TLIndexPathTools project | Docset target | Build Phases tab | Run Script.

The API documentation is also [available online][7].

[1]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Settings/Settings/SettingsTableViewController.m
[2]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Collapse/Collapse/CollapseTableViewController.m
[3]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Outline/Outline/OutlineTableViewController.m
[4]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Outline/Outline/OutlineTableViewController.m
[5]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Core%20Data/Core%20Data/CoreDataCollectionViewController.m
[6]:https://github.com/tomaz/appledoc
[7]:http://tlindexpathtools.com/api/index.html
[8]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/View%20Controller%20Backed/View%20Controller%20Backed/CollectionViewController.m
[9]:https://github.com/wtmoose/TLIndexPathTools/blob/master/Examples/Dynamic%20Height/Dynamic%20Height/DynamicHeightTableViewController.m
