package ua.edu.sumdu.essuir.entity;


import javax.persistence.*;

@Entity
@Table(name = "general_statistics")
public class GeneralStatistics {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(name = "month")
    private Integer month;

    @Column(name = "year")
    private Integer year;

    @Column(name = "count_views")
    private Integer viewsCount;

    @Column(name = "count_downloads")
    private Integer downloadsCount;

    public GeneralStatistics(){}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public Integer getViewsCount() {
        return viewsCount;
    }

    public void setViewsCount(Integer viewsCount) {
        this.viewsCount = viewsCount;
    }

    public Integer getDownloadsCount() {
        return downloadsCount;
    }

    public void setDownloadsCount(Integer downloadsCount) {
        this.downloadsCount = downloadsCount;
    }
}
